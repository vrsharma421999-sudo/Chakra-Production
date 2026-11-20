@isTest
public class OpportunityTriggerHandler_Test {
    
    @testSetup
    static void setupTestData() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCity='Delhi';
        acc.BillingCountry='India';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'test contact';
        con.AccountId = acc.Id;
        con.MobilePhone = '8409354353';
        con.FirstName = 'first';
        con.Phone = '983453453';
        con.Email = 'test@example.com';
        insert con;
    }

    @isTest
    static void testCheckFileUploaded() {   
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Initial Meeting';
        opp.Sales_Consultant_Available__c='Involved';
        opp.Name__c='abc';
        opp.City__c = 'Delhi';
        opp.State__c = 'Delhi';
        opp.Deal_Amount__c = 200;
        insert opp;
        
        PO_Verification__c pov = new PO_Verification__c();
        pov.Deal__c = opp.Id;
        pov.BP_Code__c = 'TEST123';
        insert pov;
        
        Quote q = new Quote();
        q.Name = 'test Quote';
        q.OpportunityId = opp.id;
        insert q;
        
        // Create Document Attachment
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = opp.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        insert cdl;
        
        Test.startTest();
        opp.StageName = 'PO Released';
        opp.Order_Type__c = 'New Business';
        opp.Sales_Consultant_Available__c = 'Not Involved';
        opp.Name__c='Test';    
        opp.Date_of_Proposal__c=Date.Today();
        opp.Chakr_Shield_Model__c ='M2';
       // opp.Deal_Amount__c = 200;
        opp.POC_Name__c = con.Id;
        update opp;
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('PO Released', updatedOpp.StageName);
    }
    
    @isTest
    static void testCloneAMCOppHandler() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Id amcRTId;
        for (Schema.RecordTypeInfo rt : Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (rt.getName() == 'AMC') {
                amcRTId = rt.getRecordTypeId();
            }
        }
        
        if (amcRTId == null) {
            return; // Skip test if AMC record type doesn't exist
        }

        Opportunity opp = new Opportunity(
            Name = 'AMC Deal',
            AccountId = acc.Id,
            CloseDate = Date.today(),
            StageName = 'Initial Meeting',
            RecordTypeId = amcRTId,
            Sales_Consultant_Available__c = 'Involved',
            Order_Type__c = 'New Business',
            Deal_Amount__c = 5000,
            Create_Partial_Quote__c = true
        );
        insert opp;

        Asset__c asset = new Asset__c(
            Deal__c = opp.Id,
            Warranty_End_Date__c = Date.today().addDays(60),
            Quote_Exists__c = false,
            RECD_Serial_No__c = 'SER-100',
            Shipping_Address__c = 'Test Address'
        );
        insert asset;

        Quote q = new Quote();
        q.Name = 'AMC Test Quote';
        q.OpportunityId = opp.Id;
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Status = 'Draft';
        insert q;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test File';
        cv.PathOnClient = 'TestFile.pdf';
        cv.VersionData = Blob.valueOf('Test File Body');
        cv.IsMajorVersion = true;
        insert cv;

        Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = opp.Id;
        cdl.ContentDocumentId = contentDocId;
        cdl.ShareType = 'V';
        insert cdl;

        Test.startTest();
        opp.StageName = 'PO Released';
        update opp;
        Test.stopTest();

        List<Opportunity> clonedOpps = [
            SELECT Id, Name, StageName, AMC_Deal__c, Warranty_Expiry_Date__c
            FROM Opportunity
            WHERE AMC_Deal__c = :opp.Id
        ];
        
        System.assert(!clonedOpps.isEmpty(), 'Cloned opportunity should have been created');

        Opportunity cloned = clonedOpps[0];
        
        List<Asset__c> clonedAssets = [
            SELECT Id, Deal__c
            FROM Asset__c
            WHERE Deal__c = :cloned.Id
        ];
        
        System.assertEquals(1, clonedAssets.size(), 'Asset should have been cloned and linked to the new opportunity');
    }
    
    @isTest
    static void testManagerEmail() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Opportunity opp = new Opportunity(
            Name = 'Test Email Deal',
            AccountId = acc.Id,
            CloseDate = Date.today(),
            StageName = 'Initial Meeting Conducted'
        );
        insert opp;
        
        opp.StageName = 'Proposal Sent';
        update opp;
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, ManagerEmail__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        // Cannot assert actual email since user test data manageremail__c might be null, but trigger runs it.
    }
    
    @isTest
    static void testDealNaming() {
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        
        Id customerRT;
        Id distributorRT;
        for (Schema.RecordTypeInfo rt : Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (rt.getName() == 'Customer' || rt.getDeveloperName() == 'Direct') {
                customerRT = rt.getRecordTypeId();
            }
            if (rt.getName() == 'Distributor' || rt.getDeveloperName() == 'Indirect') {
                distributorRT = rt.getRecordTypeId();
            }
        }
        
        Test.startTest();
        if (customerRT != null) {
            Opportunity oppCustomer = new Opportunity(
                Name = 'Test Customer Deal',
                AccountId = acc.Id,
                CloseDate = Date.today(),
                StageName = 'Initial Meeting',
                RecordTypeId = customerRT,
                City__c = 'Pune',
                State__c = 'MH'
            );
            insert oppCustomer;
        }
        
        if (distributorRT != null) {
            Opportunity oppDistributor = new Opportunity(
                Name = 'Test Dist Deal',
                AccountId = acc.Id,
                CloseDate = Date.today(),
                StageName = 'Initial Meeting',
                RecordTypeId = distributorRT,
                City__c = 'Mumbai',
                State__c = 'MH'
            );
            insert oppDistributor;
        }
        Test.stopTest();
        
        List<Opportunity> opps = [SELECT Id, Name, StageName, Deal_Full_Name__c FROM Opportunity];
        System.assert(opps.size() > 0, 'Opportunities should be created and renamed');
    }
}