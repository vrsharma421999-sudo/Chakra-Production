@isTest
public class CustomerAssetAPIServiceTest {
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class MockHttpErrorResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": false}');
            res.setStatusCode(500);
            return res;
        }
    }

    @isTest
    static void testCreateAssetFromUNOPoint_Success() {
        // Setup Test Data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Deal',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        PO_Verification__c pov = new PO_Verification__c(
            Deal__c = opp.Id,
            End_Client_PoC_Email__c = 'test@example.com',
            End_Client_PoC_Name__c = 'Test POC',
            End_Client_PoC_Number__c = '1234567890',
            PO__c = 'PO123'
        );
        insert pov;

        PO_Line_Item__c poli = new PO_Line_Item__c(
            PO_Verification__c = pov.Id,
            Quantity__c = 1,
            Shipping_Address__c = 'Test Address'
        );
        insert poli;

        Project__c proj = new Project__c(
            Name = 'Test Project',
            RECD_Sr_No__c = 'RECD001',
            installation_Complete_Date__c = Date.today(),
            
            deliver_State__c = 'Haryana',
            Delivery_City__c = 'Gurugram',
            PO_Line_Item__c = poli.Id,
            
            project_Full_Name__c = 'Test Project Full',
            model_Type__c = 'M2',
            CR_Signed_Date__c = Date.today(),
            commissioning_Status__c = 'Completed',
            installation_Status__c = 'Completed',
            po_Verification__c = pov.Id,
            po_Number__c = 'PO123',
            field_Quality_Approved_Date__c = Date.today(),
            qc_status__c = 'Approved',
            kva_Rating__c = 100
        );
        insert proj;

        // Set Mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call method
        Test.startTest();
        CustomerAssetAPIService.CreateAssetFromUNOPoint(new Set<Id>{proj.Id});
        Test.stopTest();

        // Verify result
        Project__c updatedProj = [SELECT Sync_UNO_Point__c FROM Project__c WHERE Id = :proj.Id];
        System.assertEquals(true, updatedProj.Sync_UNO_Point__c, 'Sync_UNO_Point__c should be true on success');
    }
    
    @isTest
    static void testCreateAssetFromUNOPoint_Error() {
        // Setup Test Data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Deal',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        PO_Verification__c pov = new PO_Verification__c(
            Deal__c = opp.Id,
            End_Client_PoC_Email__c = 'test@example.com',
            End_Client_PoC_Name__c = 'Test POC',
            End_Client_PoC_Number__c = '1234567890',
            PO__c = 'PO123'
        );
        insert pov;

        PO_Line_Item__c poli = new PO_Line_Item__c(
            PO_Verification__c = pov.Id,
            Quantity__c = 1,
            Shipping_Address__c = 'Test Address'
        );
        insert poli;

        Project__c proj = new Project__c(
            Name = 'Test Project',
            RECD_Sr_No__c = 'RECD001',
            PO_Line_Item__c = poli.Id,
            model_Type__c = 'M2',
            po_Verification__c = pov.Id
        );
        insert proj;

        // Set Mock to return error
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponseGenerator());

        // Call method
        Test.startTest();
        CustomerAssetAPIService.CreateAssetFromUNOPoint(new Set<Id>{proj.Id});
        Test.stopTest();

        // Verify result
        Project__c updatedProj = [SELECT Sync_UNO_Point__c FROM Project__c WHERE Id = :proj.Id];
        System.assertEquals(false, updatedProj.Sync_UNO_Point__c, 'Sync_UNO_Point__c should be false on error');
    }
}