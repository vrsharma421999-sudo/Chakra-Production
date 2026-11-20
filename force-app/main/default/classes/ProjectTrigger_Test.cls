@isTest
public class ProjectTrigger_Test {

    private class HttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    static void setupTestData() {

        Account acc = new Account(
            Name = 'Test Account',
            BillingCity = 'Delhi',
            BillingCountry = 'India'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Deal',
            AccountId = acc.Id,
            CloseDate = Date.today().addDays(30),
            StageName = 'Initial Meeting Conducted',
            Warranty_Expiry_Date__c = Date.today().addDays(365)
        );
        insert opp;

        PO_Verification__c pov = new PO_Verification__c(
            Deal__c = opp.Id,
            Warranty_in_Months__c = 12,

            // ✅ Required POC fields
            End_Client_PoC_Name__c = 'Test',
            End_Client_PoC_Number__c = '1234567891',
            End_Client_PoC_Email__c = 'test@example.com',

            // ✅ Required for validation
            Comissioning_and_CR_Signoff__c = 'Channel Partner'
        );
        insert pov;

        Product2 prod = new Product2(
            Name = 'Test DG Set',
            IsActive = true
        );
        insert prod;

        PO_Line_Item__c poli = new PO_Line_Item__c(
            PO_Verification__c = pov.Id,
            Product__c = prod.Id,
            Quantity__c = 1,
            DG_Type__c = 'New DG',
            DG_KVA_Rating__c = 500,
            DG_Make__c = 'Cummins',
            Turbo__c = 'Single'
        );
        insert poli;
    }

    @isTest
    static void testChangeStatus_Insert() {

        PO_Verification__c pov = [SELECT Id FROM PO_Verification__c LIMIT 1];
        PO_Line_Item__c poli = [SELECT Id FROM PO_Line_Item__c LIMIT 1];

        Test.startTest();

        Project__c pro = new Project__c(
            Name = 'Test Pro 1',
            PO_Verification__c = pov.Id,
            PO_Line_Item__c = poli.Id,
            Advance_Payment_Status__c = 'Received',
            Dispatch_Clearance_based_on_Pre_dispatch__c = 'Received',
            After_Delivery_Installation_Go_Ahead__c = 'Yes',
            Project_Execution_Status__c = 'LIVE',

            // ✅ Required fields
            Client_RECD_Received_Date__c = Date.today(),
            Field_Quality_Approved_Date__c = Date.today(),
            QC_Status__c = 'Approved'
        );

        insert pro;

        Test.stopTest();
    }

    @isTest
    static void testChangeStatusUpdate_Update() {

        PO_Verification__c pov = [SELECT Id FROM PO_Verification__c LIMIT 1];
        PO_Line_Item__c poli = [SELECT Id FROM PO_Line_Item__c LIMIT 1];

        Project__c pro = new Project__c(
            Name = 'Test Pro Update',
            PO_Verification__c = pov.Id,
            PO_Line_Item__c = poli.Id,
            Advance_Payment_Status__c = 'Pending',
            Dispatch_Clearance_based_on_Pre_dispatch__c = 'Pending',
            Project_Execution_Status__c = 'LIVE',
            Final_Payment_Status__c = 'Pending',
            Project_Status__c = 'Finance Team',

            // ✅ Required fields
            Client_RECD_Received_Date__c = Date.today(),
            Field_Quality_Approved_Date__c = Date.today(),
            QC_Status__c = 'Approved'
        );

        insert pro;

        Test.startTest();

        pro.Advance_Payment_Status__c = 'Received';
        pro.Dispatch_Clearance_based_on_Pre_dispatch__c = 'Received';
        pro.Final_Payment_Status__c = 'Received';

        update pro;

        Test.stopTest();
    }

    @isTest
    static void testHandleCRSignOf() {

        Test.setMock(HttpCalloutMock.class, new HttpMock());

        PO_Verification__c pov = [SELECT Id FROM PO_Verification__c LIMIT 1];
        PO_Line_Item__c poli = [SELECT Id FROM PO_Line_Item__c LIMIT 1];

        Project__c pro = new Project__c(
            Name = 'Test CR Sign',
            PO_Verification__c = pov.Id,
            PO_Line_Item__c = poli.Id,
            CR_Signed__c = 'No',
            Project_Execution_Status__c = 'LIVE',

            // ✅ Required before CR Signed = Yes
            Installation_Complete_Date__c = Date.today(),
            Field_Quality_Approved_Date__c = Date.today(),
            QC_Status__c = 'Approved',
            Client_RECD_Received_Date__c = Date.today(),

            // ✅ Important: helps system derive warranty dates
            CR_Signed_Date__c = Date.today()
        );

        insert pro;

        Test.startTest();

        pro.CR_Signed__c = 'Yes';
        pro.RECD_Sr_No__c = '12345';

        update pro;

        Test.stopTest();
    }
}