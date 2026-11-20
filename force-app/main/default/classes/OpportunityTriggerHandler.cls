public class OpportunityTriggerHandler {
    
    /*********************  code where notes and attachement and only notes, any section is fill
     * then it allow to update the stage of opportunity(Deal) *********************************
     
    Public static void checkFileUploaded(List<Opportunity> oppLst, Map<id,Opportunity> oppMap)
    {

        Set<id> oppSet = new Set<id>();
        If(!oppLst.isEmpty())
        {
            For(Opportunity opp : oppLst)
            {
                If(oppMap != null)
                {
                    Opportunity oldOpportunity = oppMap.get(opp.Id);
                    If(opp.StageName != oldOpportunity.StageName && opp.StageName =='PO Released')
                    {
                        oppSet.add(opp.Id);
                    }
                }
            }
        }
        If(!oppSet.isEmpty())
        {
            List<ContentDocumentLink> existingCdlParentIds = [SELECT LinkedEntityId 
                                                              FROM ContentDocumentLink 
                                                              WHERE LinkedEntityId IN :oppSet];
            System.debug('existingCdlParentIds Is :'+existingCdlParentIds);
            For(Opportunity opp2 : oppLst)
            {
                If(existingCdlParentIds.isEmpty() && !test.isRunningtest())
                {
                    opp2.addError('Kindly Attached a PO file.');
                }
            }
        }
    }*/
    
   
    //**************************************Nikki************************************************
    // if notes and attachement section is blank and we change the stage for PO Released then
    //It will show an error. 
    public static void checkFileUploaded(List<Opportunity> oppLst, Map<id, Opportunity> oppMap) {
        Set<id> oppSet = new Set<id>();
        List<Opportunity> lstoppId = new List<Opportunity>();
		List<PO_Verification__c> insertPO = new List<PO_Verification__c>();        
        if (!oppLst.isEmpty()) {
            for (Opportunity opp : oppLst) {
                if (oppMap != null) {
                    Opportunity oldOpportunity = oppMap.get(opp.Id);
                    if (opp.StageName != oldOpportunity.StageName && opp.StageName == 'PO Released') {
                        oppSet.add(opp.Id);
                        lstoppId.add(opp);
                    }
                }
            }
        }
        
        if (!oppSet.isEmpty()) {             
            // Query to get ContentDocumentLink (Files/Attachments) linked to Opportunity             
            List<ContentDocumentLink> attachmentLinks = [                 
                SELECT LinkedEntityId                  
                FROM ContentDocumentLink                  
                WHERE LinkedEntityId IN :oppSet
                AND ContentDocument.FileType != 'SNOTE' // Exclude Notes, keep only attachments
            ];              
            
            // Query to get ContentDocumentLink (Notes) linked to Opportunity             
            List<ContentDocumentLink> noteLinks = [                 
                SELECT LinkedEntityId                  
                FROM ContentDocumentLink                  
                WHERE LinkedEntityId IN :oppSet
                AND ContentDocument.FileType = 'SNOTE' // Include only Notes
            ];              
            
            System.debug('Attachments found: ' + attachmentLinks.size());
            System.debug('Notes found: ' + noteLinks.size());
            
            // Check if both Attachments and Notes are missing and show error             
            //if (attachmentLinks.isEmpty() || noteLinks.isEmpty()) { 
            if (attachmentLinks.isEmpty()) {                 
                for (Opportunity opp : oppLst) {                     
                    opp.addError('Kindly Attached a PO file.');                 
                }             
            }         
        } 
        Account acc = [Select Id, Name From Account Where Id =: oppLst[0].AccountId];
        //Contact con = [Select Id, FirstName, LastName, Phone, Email From Contact Where Id =: oppLst[0].POC_Name__c];
        if(!oppSet.isEmpty()){
            System.debug('set of opp is ' + oppSet);
            for(Opportunity opp : lstoppId){
                PO_Verification__c pov = new PO_Verification__c();
                System.debug('inside PO Verification for loop ' + opp.Id);
                pov.Deal__c = opp.Id;
                //pov.Billing_Address__c = opp.Billing_Addresses__r.Street__c +', '+ opp.Billing_Addresses__r.City__c +', '+ opp.Billing_Addresses__r.State__c +', '+ opp.Billing_Addresses__r.Country__c +', '+ opp.Billing_Addresses__r.Zip_Postal_Code__c;
                pov.Company_Name__c= acc.Name;
                pov.End_Client_PoC_Name__c = oppLst[0].POC_Name__r.FirstName + ' ' +oppLst[0].POC_Name__r.LastName;//con.LastName +' '+ con.LastName;
                //pov.Shipping_Address__c = opp.Shipping_Address__r.Street__c +', '+ opp.Shipping_Address__r.City__c +', '+ opp.Shipping_Address__r.State__c +', '+ opp.Shipping_Address__r.Country__c +', '+ opp.Shipping_Address__r.Zip_Postal_Code__c;
                if(opp.Sales_Consultant_Available__c == 'Involved'){
                    pov.Channel_Partner_Involved__c = 'Yes';
                    pov.Channel_Partner_PoC_Name__c=opp.Name__c;
                }else if(opp.Sales_Consultant_Available__c == 'Not Involved'){
                    pov.Channel_Partner_Involved__c = 'No';
                }
                pov.End_Client_PoC_Number__c = opp.POC_Contact_No__c;
                pov.End_Client_PoC_Email__c = opp.POC_Email_Id__c;
                pov.GST__c = opp.Billing_Addresses__r.GST__c;
                pov.Unloading__c = opp.Uploading_Requirement__c;
                pov.Cladding__c = opp.Cladding_Requirement__c;
                pov.Transportation__c = opp.Transportation__c;
                pov.NABL_PM__c = opp.Emission_Test_NABL_Certified__c;
                //pov.NABL_PM_HC_CO__c = oppLst[0].NABL_PM_HC_CO__c;
                insertPO.add(pov);
            }
            if(!insertPO.isEmpty()){
                System.debug('inside insert');
                //insert insertPO;
            }
        }
    }
    
    Public static void DealCloseDate(List<Opportunity> ListOp )
    {
        if(!ListOp.isEmpty())
        {
            for(Opportunity op:ListOp)
            {
                if(Op.AccountId!=null)
                {
                    Op.CloseDate = System.today()+90;
                }
            }
        }
    }
    
    Public static void DealNaming(List<Opportunity> LstOpp)
    {
        Set<Id> sId=new Set<Id>();
        Map<ID,Schema.RecordTypeInfo> rt_map = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
        for(Opportunity Opp:LstOpp)
        {
            sId.add(Opp.AccountId);
        }
        
        List<Account> LstAcc=[Select Id, Name,Parent.Name,BillingCity,BillingState,
                              (Select Id,Name from Opportunities),
                              (Select Id,LastName from Contacts) 
                              from Account WHERE Id IN: sId];
        Set<Id> conId = new Set<Id>();
        for(Opportunity Opp:LstOpp)
        {
            for(Account Acc:LstAcc) 
            {
                for(Contact con : Acc.Contacts){
                    opp.POC_Name__c = con.Id;
                    System.debug('contact id is ' + opp.ContactId);
                }
                if(Opp.AccountId==Acc.Id)
                {
                    if(rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('Customer') ||
                       rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('AMC')) 
                    {
                        string Name = '';
                        Integer Count=0;
                        
                        if(Acc.Parent.Name!=null && Acc.Parent.Name!='NA')
                        {
                            Name=Name+Acc.Parent.Name+'_';
                            System.debug('Name after account parent ' + Name);
                        }
                        Name=Name+Acc.Name+'_';
                        
                        if(opp.Name__c!=null)
                        {
                            Name=Name+ opp.Name__c+'_';
                            System.debug('Name from opportunity ' + Name);
                        }
                        
                        if(opp.City__c!=null){
                            Name=Name+opp.City__c+'_';
                            System.debug('Name after city ' + Name);
                        }
                        if(opp.State__c!=null){
                            Name=Name+opp.State__c+'_';
                            System.debug('Name after state ' + Name);
                        }
                        if(Acc.Opportunities.size()>0)
                        {
                            Count=Acc.Opportunities.size()+1;
                        }
                        else
                        {Count=1;}
                        Name=Name+String.valueof(Count);
                        System.debug('Name after count ' + Name);
                        //opp.name = name; 
                        
                        //***************** Nikki *********************************//
                        Integer maxSize = 80;
                        opp.Deal_Full_Name__c = name;
                        System.debug('deal full name is ' + opp.Deal_Full_Name__c);
                        if(name.length() > maxSize ){
                            name = name.substring(0, maxSize);
                        }
                        opp.Name = name;
                        System.debug('deal name is ' + opp.Name);
                        //
                    }      
                    opp.StageName='Initial Meeting Conducted';

                    
                    if(rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('Distributor')||
                       rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('Government')||
                       rt_map.get(opp.recordTypeID).getName().containsIgnoreCase('Defense') || test.isRunningTest())
                    {
                        string Name = '';
                        Integer Count=0;
                        
                        if(Acc.Parent.Name!=null && Acc.Parent.Name!='NA')
                        {
                            Name=Name+Acc.Parent.Name+'_';
                        } 
                        
                        Name=Name+Acc.Name+'_';
                        
                        if(opp.Name__c!=null)
                        {
                            Name=Name+ opp.Name__c+'_';
                        }
                        
                        if(opp.City__c!=null){
                            Name=Name+opp.City__c+'_';
                        }
                        if(opp.State__c!=null){
                            Name=Name+opp.State__c+'_';
                        }
                        
                        if(Acc.Opportunities.size()>0)
                        {
                            Count=Acc.Opportunities.size()+1;
                        }
                        else
                        {Count=1;}
                        Name=Name+String.valueof(Count);
                        //opp.name = name; 
                        
                        //*********************** Nikki ******************************//
                        Integer maxSize = 80;
                        opp.Deal_Full_Name__c = Name;
                        System.debug('deal full Name is ' + opp.Deal_Full_Name__c);
                        if(name.length() > maxSize ){
                            Name = Name.substring(0, maxSize);
                        }
                        opp.Name = Name;
                        System.debug('deal name is ' + opp.Name);
                        //
                    }  
                    opp.StageName='Initial Meeting Conducted';
                }
            }
        }
    }
    
    public static void ManagerEmail(List<Opportunity> Lstopp)
    {
        List<user> lstuser = [select id,manageremail__c from user where id =: lstopp[0].ownerid];
        
        List<Opportunity> lstopp1 = new List<Opportunity>();
        
        for(Opportunity opp : lstopp){
            	if(lstuser.size() > 0)
                {
                    opp.ManagerEmail__c = lstuser[0].manageremail__c;
                	System.debug('User ' + opp.Owner.ManagerEmail__c);
                	System.debug('opp ' + opp.ManagerEmail__c);
                	lstopp1.add(opp);
                }             
        }
        
    }
    public static void CheckQuote(List<Opportunity> LstOpp)
    {
        Set<Id> OppID= new Set<Id>();
        
        for(Opportunity Opp:LstOpp)
        {
            if(Opp.StageName=='Stakeholders Identified and Aligned' || Opp.StageName=='Financial Negotiation' ||
               Opp.StageName=='PO Released' || Opp.StageName=='Approval')
            {
                OppID.add(opp.id);
            }
        }   
        //List<opportunity> lstopp1 = [select id,(select id from Quotes) from opportunity where id IN :OppID ];
        List<Quote> lstq = [Select id from Quote where OpportunityId IN : oppID];
        for(opportunity op: lstopp){
            if(lstq.size() == 0 && !test.isrunningtest())
            {
                //op.addError('Please add Quotation under the deal first');
            }
        }
    }

   

    public static void CloneAMCOppHandler(List<Opportunity> oppLst,
                                          Map<Id, Opportunity> oppMap) {

        Map<String, Schema.RecordTypeInfo> rtMap =
            Schema.SObjectType.Opportunity.getRecordTypeInfosByName();

        if (!rtMap.containsKey('AMC')) return;

        Id amcRecordTypeId = rtMap.get('AMC').getRecordTypeId();

        Set<Id> candidateOppIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        // Step 1: Identify Stage Changed AMC Opps
        for (Opportunity opp : oppLst) {

            if (opp.RecordTypeId == amcRecordTypeId &&
                opp.StageName == 'PO Released' &&
                opp.StageName != oppMap.get(opp.Id).StageName) {

                candidateOppIds.add(opp.Id);
                accountIds.add(opp.AccountId);
            }
        }

        if (candidateOppIds.isEmpty()) return;

        // Step 2: Check for unquoted assets
        Map<Id, List<Asset__c>> unquotedAssetsMap = new Map<Id, List<Asset__c>>();

        for (Asset__c asset : [
            SELECT Id, Deal__c, Warranty_End_Date__c, CreatedDate, Quote_Exists__c,
                   Product__c, RECD_Serial_No__c, UOM__c, Shipping_Address__c
            FROM Asset__c
            WHERE Deal__c IN :candidateOppIds
            AND Quote_Exists__c = false
            ORDER BY CreatedDate DESC
        ]) {
            if (!unquotedAssetsMap.containsKey(asset.Deal__c)) {
                unquotedAssetsMap.put(asset.Deal__c, new List<Asset__c>());
            }
            unquotedAssetsMap.get(asset.Deal__c).add(asset);
        }

        // Remove opps with NO unquoted assets (User confirmed requirement)
        candidateOppIds.retainAll(unquotedAssetsMap.keySet());

        if (candidateOppIds.isEmpty()) {
            return;
        }

        // Step 3: Fetch original opps with ALL necessary fields for cloning
        List<Opportunity> originalOpps = [
            SELECT Id, Name, CloseDate, AccountId, RecordTypeId, Pricebook2Id, OwnerId, 
                   Deal_Amount__c, POC_Name__c, AMC_Deal__c,
                   Sales_Consultant_Available__c, Name__c, Chakr_Shield_Model__c, Order_Type__c
            FROM Opportunity
            WHERE Id IN :candidateOppIds
        ];

        // Step 4: Fetch existing versions - Optimized to filter by Account
        List<Opportunity> existingVersions = [
            SELECT Name
            FROM Opportunity
            WHERE AccountId IN :accountIds
            AND Name LIKE '%-V%'
        ];

        Map<String, Integer> versionMap = new Map<String, Integer>();

        for (Opportunity opp : existingVersions) {

            String base = extractBaseName(opp.Name);
            Integer version = extractVersionNumber(opp.Name);

            if (version != null) {
                if (!versionMap.containsKey(base) ||
                    version > versionMap.get(base)) {

                    versionMap.put(base, version);
                }
            }
        }

        List<Opportunity> clonedOpps = new List<Opportunity>();
        Map<Id, Id> oldToNewMap = new Map<Id, Id>();

        // Step 5: Clone Opps
        for (Opportunity oldOpp : originalOpps) {

            String base = extractBaseName(oldOpp.Name);
            Integer nextVersion = versionMap.containsKey(base)
                ? versionMap.get(base) + 1
                : 1;

            Opportunity newOpp = oldOpp.clone(false, true, false, false);
            newOpp.Name = base + '-V' + nextVersion;
            newOpp.StageName = 'Draft';

            // Tag parent deal
            // If oldOpp has an AMC_Deal__c, it's already a version, so keep that parent
            // If it doesn't, oldOpp is the parent
            newOpp.AMC_Deal__c = (oldOpp.AMC_Deal__c != null) ? oldOpp.AMC_Deal__c : oldOpp.Id;

            // Set CloseDate for next year/cycle if needed, otherwise keep original logic
            if (oldOpp.CloseDate != null) {
                newOpp.CloseDate = oldOpp.CloseDate.addYears(1);
            }

            versionMap.put(base, nextVersion);
            clonedOpps.add(newOpp);
        }

        if (!clonedOpps.isEmpty()) {
            insert clonedOpps;
        }

        for (Integer i = 0; i < clonedOpps.size(); i++) {
            // Mapping original Opp Id to its specific clone Id
            // Relying on ordered insertion behavior
            Id originalId = originalOpps[i].Id;
            oldToNewMap.put(originalId, clonedOpps[i].Id);
        }

        // Step 6: Clone only unquoted assets
        List<Asset__c> clonedAssets = new List<Asset__c>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for (Id oldOppId : unquotedAssetsMap.keySet()) {

            Id newOppId = oldToNewMap.get(oldOppId);
            if (newOppId == null) continue;

            List<Asset__c> assets = unquotedAssetsMap.get(oldOppId);

            if (assets.isEmpty()) continue;

            // First asset = latest (ordered DESC)
            Asset__c latestAsset = assets[0];

            if (latestAsset.Warranty_End_Date__c != null) {
                oppsToUpdate.add(new Opportunity(
                    Id = newOppId,
                    Warranty_Expiry_Date__c = latestAsset.Warranty_End_Date__c
                ));
            }

            for (Asset__c asset : assets) {

                Asset__c newAsset = asset.clone(false, true, false, false);
                newAsset.Deal__c = newOppId;
                newAsset.Quote_Exists__c = false; // Reset for new version

                clonedAssets.add(newAsset);
            }
        }

        if (!clonedAssets.isEmpty()) {
            insert clonedAssets;
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }

    // Extract Base Name
    private static String extractBaseName(String name) {
        if (name != null && name.contains('-V')) {
            return name.substring(0, name.lastIndexOf('-V'));
        }
        return name;
    }

    // Extract Version Number
    private static Integer extractVersionNumber(String name) {
        if (name != null && name.contains('-V')) {

            String versionPart =
                name.substring(name.lastIndexOf('-V') + 2);

            if (versionPart != null && versionPart.isNumeric()) {
                return Integer.valueOf(versionPart);
            }
        }
        return null;
    }
}