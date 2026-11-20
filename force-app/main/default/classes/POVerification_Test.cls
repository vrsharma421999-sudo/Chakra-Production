@isTest
public class POVerification_Test {
    public static testmethod void m1(){
        test.startTest();
         Id adminProfId = [Select id from Profile WHERE Name=:'System Administrator'].Id;
        User adminUser = new User();
        adminUser.FirstName = 'Admin';
        adminUser.LastName = 'testUser';
        adminUser.Email = 'AdmintestUserak@test.com';
        adminUser.Username = 'AdmintestUserak@test.com';
        adminUser.ProfileId = adminProfId;
        adminUser.IsActive = true;
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.Alias = adminUser.FirstName.substring(0,1) + adminUser.LastName.substring(0,4);
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.TimeZoneSidKey = 'GMT';        
        insert adminUser;
        
        Id stdProfId = [Select id from Profile WHERE Name=:'Standard User'].Id;
        User stdUser = new User();
        stdUser.FirstName = 'Admin';
        stdUser.LastName = 'testUser';
        stdUser.Email = 'ramkrishna@captivaenergy.co';
        stdUser.Username = 'stdtestUserak@test.com';
        stdUser.ProfileId = stdProfId;
        stdUser.IsActive = true;
        stdUser.LanguageLocaleKey = 'en_US';
        stdUser.LocaleSidKey = 'en_US';
        stdUser.Alias = stdUser.FirstName.substring(0,1) + stdUser.LastName.substring(0,4);
        stdUser.EmailEncodingKey = 'UTF-8';
        stdUser.TimeZoneSidKey = 'GMT';        
        insert stdUser;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Nikki Pandey';
        opp.CloseDate = System.today();
        opp.StageName = 'Expired';
        insert opp;
        
        Product2 prod = new Product2();
        
        Deal_DG__c dg = new Deal_DG__c();
        dg.Deal__c = opp.Id;
        dg.DG_KVA_Rating__c = 12;
        //dg.DG_Make__c = 'test';
        dg.Quantity__c = 1;
        dg.Product__c = prod.Id;
        insert dg;
        
        PO_Verification__c pov = new PO_Verification__c();
        pov.Deal__c = opp.Id;
        pov.OwnerId = adminUser.Id;
        pov.Status__c = 'TC in Process';
        pov.Approval_Status__c = 'Approval Pending';
        pov.BP_Code__c = 'qwerty12345';
        insert pov;
        pov.Approval_Status__c = 'Approved';
        update pov;
        //pov.Approval_Status__c = 'Rejected';
        //update pov;
        
        /*pov.OwnerId = '005Uz00000AZUv7';
        update pov;
        
        pov.Status__c = 'FC in Progress';
        update pov;*/
        
        PO_Line_Item__c poli = new PO_Line_Item__c();
        poli.PO_Verification__c = pov.Id;
        poli.DG_KVA_Rating__c = dg.DG_KVA_Rating__c;
        //poli.DG_Make__c = dg.DG_Make__c;
        poli.Quantity__c = dg.Quantity__c;
        //poli.Product_Search_KVA_Rating__c = dg.Product__r.Name;
        insert poli;

        test.stopTest();
    }
    
    public static testmethod void m2(){
        test.startTest();
        Opportunity opp = new Opportunity();
        opp.Name = 'Nikki Pandey';
        opp.CloseDate = System.today();
        opp.StageName = 'Expired';
        insert opp;
        
        Product2 prod = new Product2();
        Deal_DG__c dg = new Deal_DG__c();
        dg.Deal__c = opp.Id;
        dg.DG_KVA_Rating__c = 12;
        //dg.DG_Make__c = 'test';
        dg.Quantity__c = 1;
        dg.Product__c = prod.Id;
        insert dg;
        
        PO_Verification__c pov = new PO_Verification__c();
        pov.Deal__c = opp.Id;
        pov.Status__c = 'TC in Process';
        pov.Approval_Status__c = 'Approval Pending';
        pov.BP_Code__c = 'qwerty12345';
        insert pov;
        pov.Status__c = 'PO Approved';
        pov.Approval_Status__c = 'Approved';
        update pov;
        pov.Approval_Status__c = 'Rejected';
        update pov;
        
        /*pov.OwnerId = '005Uz00000AZUv7';
        update pov;
        
        pov.Status__c = 'FC in Progress';
        update pov;*/
        
        PO_Line_Item__c poli = new PO_Line_Item__c();
        poli.PO_Verification__c = pov.Id;
        poli.DG_KVA_Rating__c = dg.DG_KVA_Rating__c;
        //poli.DG_Make__c = dg.DG_Make__c;
        poli.Quantity__c = dg.Quantity__c;
        //poli.Product_Search_KVA_Rating__c = dg.Product__r.Name;
        insert poli;

        test.stopTest();
    }
    
    public static testmethod void m3() {
        test.startTest();
        Opportunity opp = new Opportunity();
        opp.Name = 'Rubal Kaushik';
        opp.CloseDate = System.today();
        opp.StageName = 'Expired';
        insert opp;
        
        PO_Verification__c po = new PO_Verification__c();
        po.Deal__c = opp.Id;
        po.Status__c = 'TC in Process';
        po.Approval_Status__c = 'Approval Pending';
        po.GST__c = 'Cloud Panthers A Salesforce Company';
        po.PO__c  = 'Cloud Panthers A Salesforce Company';
        po.Cladding__c = 'Client';
        po.NABL_PM__c = 'Chakr';
        po.Unloading__c = 'Chakr';
        po.NABL_PM_HC_CO__c = 'Chakr';
        po.Transportation__c = 'Chakr';
        po.DOFF__c = 'Chakr';
        po.Piping_and_Structure__c = 'Chakr';
        po.GA_Drawing__c = 'Chakr';
        po.Comissioning_and_CR_Signoff__c = 'Chakr';
        po.BP_Code__c = 'qwerty12345';
        insert po;
 
        List<PO_Line_Item__c> poLineItemList = new List<PO_Line_Item__c>();
        for(integer i=1;i<=2;i++) {
        PO_Line_Item__c poLine  = new PO_Line_Item__c();
        poLine.PO_Verification__c  = po.Id;
        poLine.Quantity__c = 5.0;
        poLine.Device_per_unit__c = 100.0;
        poLine.Installation_per_unit__c = 10.0;
        poLine.Transportation_per_unit__c = 10.0;
        poLine.Additional_Cost__c = 10.0;
        poLineItemList.add(poLine); 
        }
        insert poLineItemList;
        
        Milestone__c  mStone = new Milestone__c();
        mStone.PO_Verification__c = po.Id;
        mStone.Milestone_Amount__c = 1000;
        mStone.Milestone_Amount_with_GST__c = 2000;
        mStone.GST__c = 18.00;
        mStone.Field1__c = 100;
        insert mStone;
        
        PO_Line_Item__c poLineItem = [Select Id From PO_Line_Item__c Where PO_Verification__c =:po.id Limit 1];
        
        if(poLineItem != NULL){
        	delete poLineItem;
        }else{
            System.debug(' No PO line item found.');
        }
        
        test.stopTest();
       
    }
    
}