public class QuoteTrgClass {
	/*
    public static void sendMailAfterInsert(List<Quote> qList)
    {
        Set<Id> oppId = new Set<Id>();
        if(!qList.isEmpty())
        {
            for(Quote q : qList)
            {
                if(q.OpportunityId != Null)
                {
                    oppId.add(q.OpportunityId);
                }
            }
        }
        if(!oppId.isEmpty())
        {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(Quote qt : qList)
            {
               for(Opportunity opp : [Select Id,Name, StageName, ManagerEmail__c, OwnerId From Opportunity Where Id =: oppId])
             	{
                  User userInfo = [Select Id, Email,ManagerEmail__c From User Where Id =: opp.OwnerId];
                	if(opp.StageName == 'Send for Quote Generation' && userInfo.ManagerEmail__c!=null)
                	{
                    	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                       // User userInfo = [Select Id, Email,ManagerEmail__c From User Where Id =: opp.OwnerId];
                    	email.setToAddresses(new String[] {userInfo.Email});
                        email.setCcAddresses(new String[] {userInfo.ManagerEmail__c});
        				email.setSubject('Quotation : '+qt.Name+' is generated for '+ opp.Name +'.');
        				email.setPlainTextBody('Quotation is generated for ('+ opp.Name+')');
                    	emails.add(email);
                	}
            	} 
            }
            if(!emails.isEmpty())
            {
                Messaging.sendEmail(emails);
            }
        }
    }*/
    
    public static void updateOrInsertTotalPrice(List<Quote> lstq , Map<Id,Quote> oldmap){
        Set<Id> oppId = new Set<Id>();
        for(Quote quo: lstq){
            if(quo.OpportunityId != null){
                oppId.add(quo.OpportunityId);
            }
        }
        List<Quote> qList = [Select Id, TotalPrice, OpportunityId From Quote Where OpportunityId =: oppId];
        List<AggregateResult> results = [SELECT Id ids, SUM(TotalPrice) totalAmount FROM Quote WHERE OpportunityId =: oppId GROUP BY Id];
        Decimal amount = 0;
        for(AggregateResult agg : results){
            amount += (Decimal)agg.get('totalAmount');
        }
        
        for(Id ids : oppId){
            Opportunity opp = new Opportunity();
            opp.Id = ids;
            opp.Quote_Total_Price__c = amount;
            update opp;
        }
    }
    
    public static void addTermsAndConditions(List<Quote> lstq){
        System.debug('list of quote is ' + lstq);
        String TNC = '1) Any delays in client approvals or clearances during the course of the project shall not be attributable to Chakr Innovation, and Chakr shall bear no liability for the resulting impact on timelines. \n 2) DG stack should be as per OEM standards, i.e., stack back pressure at rated load should be less than 1kPa. In case of deviation, if required, the customer has to modify the stack as per Chakrs recommendation.  \n 3) To ensure optimal and continuous regeneration of the RECD system, Chakr Innovation recommends the following operational guidelines for DG sets: \n a) If daily idling is practiced: Operate the DG set at above 40% load for a minimum of 2 hours over the course of a month. \n b) If daily idling is not practiced, ensure the DG set operates at above 40% load for at least 20% of the total monthly runtime. \n  Note: These practices are not mandatory but essential to maintain the efficiency and longevity of the RECD system by supporting its continuous regeneration cycle. \n 4) The Engine AMC must adhere to the respective OEM’s maintenance norms, and service reports for the past two years must be provided to Chakr Innovation prior to installation. There should be no major pending issues, such as overdue C or D checks, injector faults, engine breakdowns, or any other significant engine-related concerns. Chakr Innovation shall not be held liable for any performance issues, damage, or failures arising in the RECD or associated systems due to the ill health or improper maintenance of the DG set. \n 5)It is mandatory for the client to maintain an active Annual Maintenance Contract (AMC) for the RECD with Chakr Innovation during the entire warranty period and thereafter for continued support. In the absence of such an AMC, Chakr Innovation shall bear no responsibility for any equipment malfunction, performance degradation, or non-compliance with applicable emission norms or regulatory requirements. Any liabilities, penalties, or consequences arising due to lack of prescribed maintenance or non-compliance shall rest solely with the client. \n 6) Any modifications to the stack layout after commissioning of the RECD device should be consulted with Char Innovation Pvt. Ltd. \n 7)The silencer will be dismantled from the system and formally handed over to the client for safekeeping. \n 8) Back-up DG, if required, will be provided by the client whenever there are constraints for providing the required shutdown as per shared installation requirements. Delays arising from the absence of such an arrangement shall not be attributable to Chakr Innovation \n 9)As per the above General Scope of Work, any modification required to accommodate the RECD device that falls outside the agreed scope shall be in the Clients scope. \n 10) Use of CJ-4 grade lubrication oil and BSVI-compliant diesel fuel is to ensure performance and durability of the RECD system.';
        System.debug('string is ' + TNC);
        for(Quote q : lstq){
            if(q.Terms_And_Conditions__c == null){
                q.Terms_And_Conditions__c = TNC;
            }
        }
    }
    
    public static void addGeneralScopeofwork(List<Quote> lstq){
        System.debug('list of quote is ' + lstq);
        String GSW = '1) In case the existing foundation is found to be inadequate for RECD mounting, any additional civil work or structural modifications required for proper installation shall be under the Client’s scope.\n 2) Client should provide space for material storage once it is delivered on-site.\n 3) Client should have the necessary arrangements like scaffolding / ladder for accessibility of Retrofit Emission Control Device (RECD) during site mapping and maintenance.\n 4) Client shall provide the necessary DG shutdown during installation activities. A detailed shutdown schedule and installation timeline will be shared by Chakr Innovation in advance. Any delay in providing the required shutdown may impact the overall project completion timeline, for which Chakr Innovation shall not be held liable. \n 5) Client should provide Constructional power (240V AC supply) to enable positional welding i.e., Welding will be done on the actual location. \n 6) Incoming cable & Industrial power boards will be within the clients scope. Recommended specifications are as below: \n a) One 15A industrial power board with MCB near to the Chakr Shield panel location which will receive power supply from grid/UPS.  \n b)  One 15A industrial power board with MCB near to the Chakr Shield panel location which will receive power supply from DG output. \n c) Recommended Cable size- 1.5 sq. mm three core flexible/armoured cable.\n 7) Client should allow the Installation team to run DG on maximum load for at least 2 hrs at the time of testing. \n 8) Any Returnable Items, extra consumables, tools, and equipment used for installation, will be Chakr Innovation’s property and will be taken back after completion of installation. \n 9) Power requirement – 240V AC supply from mains will be required all the time even when DG is not running. This is required to monitor the working of the automation system. \n 10) The device is covered under a warranty of 12 months from the date of commissioning, or 18 months from the date of delivery, whichever occurs earlier, as outlined in Point No. 4. Standard terms and conditions apply. \n 11) Unloading will be in Clients Scope.\n 12) All structural and installation drawings provided by Chakr Innovation are prepared in accordance with Chakr’s internal safety standards and norms. Should the client require any additional safety features, specifications, or modifications beyond these standards—including changes to access structures, protective enclosures, or materials—the same shall be executed upon request and will be chargeable separately .  ';
        System.debug('string is ' + GSW);
        for(Quote q : lstq){
            if(q.General_Scope_of_Work__c == null){
                q.General_Scope_of_Work__c = GSW;
            }
        }
    }
    
    public static void uncheckOldQuote(List<Quote> newQuote){
        for(Quote q:newQuote){
            if(q.Recent_Quote__c!=True){
                q.Recent_Quote__c=True;
            }
        }
        
        Set<Id> OppId=new Set<Id>();
        for(Quote quo:newQuote){
            If(quo.OpportunityId!=NULL){
                OppId.add(quo.OpportunityId);
            }
        }
        
        List<Quote> quoteList=[select Id,OpportunityId,Recent_Quote__c from Quote 
                               where Recent_Quote__c=True AND OpportunityId IN :OppId];
        List<Quote> updateList=new List<Quote>();
        for(Quote q:quoteList){
            q.Recent_Quote__c=false;
            updateList.add(q);
        }
        if(!updateList.isEmpty()){
            update updateList;
        }
    }
    
    //populate supplier details -added by Vanshika (02/09/2026)
    public static void populateSupplierDetails(List<Quote> newList, Map<Id, Quote> oldMap) {
        

        Set<Id> oppIds = new Set<Id>();
        for (Quote q : newList) {
            if (q.OpportunityId != null) {
                oppIds.add(q.OpportunityId);
            }
        }

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        if (!oppIds.isEmpty()) {
            oppMap = new Map<Id, Opportunity>(
                [SELECT Id, RecordType.DeveloperName, RecordType.Name FROM Opportunity WHERE Id IN :oppIds]
            );
        }

        for (Quote q : newList) {
            // Bypass Chakr Marjak quotes
            if (q.OpportunityId != null && oppMap.containsKey(q.OpportunityId)) {
                Opportunity parentOpp = oppMap.get(q.OpportunityId);
                if (parentOpp.RecordType != null && 
                   (parentOpp.RecordType.DeveloperName == 'Chakr_Marjak' || parentOpp.RecordType.Name == 'Chakr Marjak')) {
                    continue;
                }
            }

            Quote oldQ = (oldMap != null) ? oldMap.get(q.Id) : null;

            // Default to Gurugram Plant if option is blank on insert
            if (String.isBlank(q.Supplier_Address_Option__c)) {
                q.Supplier_Address_Option__c = 'Gurugram Plant';
            }

            Boolean optionChanged = (oldQ == null) || (q.Supplier_Address_Option__c != oldQ.Supplier_Address_Option__c);

            if (q.Supplier_Address_Option__c == 'Gurugram Plant') {
                if (optionChanged || String.isBlank(q.Supplier_Company_Name__c)) {
                    q.Supplier_Company_Name__c = 'Chakr Innovation Private Limited - Gurugram Plant';
                    q.Supplier_Street__c = 'Sector 35, Narsinghpur Industries Area, Gurugram';
                    q.Supplier_City_State_Zip__c = 'Gurugram, (Haryana - 6), India - 122004';
                    q.Supplier_GSTIN__c = '06AAGCC5131K1ZR';
                }
            } else if (q.Supplier_Address_Option__c == 'Gurugram HO') {
                if (optionChanged || String.isBlank(q.Supplier_Company_Name__c)) {
                    q.Supplier_Company_Name__c = 'Chakr Innovation Private Limited - Gurugram HO';
                    q.Supplier_Street__c = '535, Udyog Vihar Phase 5, Gurugram, Haryana';
                    q.Supplier_City_State_Zip__c = 'Gurugram, (Haryana - 6), India - 122001';
                    q.Supplier_GSTIN__c = '06AAGCC5131K1ZR';
                }
            } else if (q.Supplier_Address_Option__c == 'Other / Custom Address') {
                // Retain manual custom entries
            }
        }
    }

    
}