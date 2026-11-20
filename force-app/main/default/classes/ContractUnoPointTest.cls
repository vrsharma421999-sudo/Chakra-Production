@isTest
public class ContractUnoPointTest {

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSyncContractLineItems() {
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
            Quantity__c = 1
        );
        insert poli;

        Project__c proj = new Project__c(
            Name = 'Test Project',
            PO_Line_Item__c = poli.Id,
            PO_Verification__c = pov.Id,
            Model_Type__c = 'M2',
            Deliver_State__c = 'Haryana',
            Delivery_City__c = 'Gurugram',
            Commissioning_Status__c = 'Completed',
            Installation_Status__c = 'Completed',
            QC_status__c = 'Approved'
        );
        insert proj;

        Contract__c con = new Contract__c(
            Deal__c = opp.Id,
            PO_Verification__c = pov.Id
        );
        insert con;

        Contract_Line_Item__c cli = new Contract_Line_Item__c(
            Contract__c = con.Id,
            PO_Line_Item__c = poli.Id,
            RECD_Serial_No__c = 'CLI001',
            Contract_Start_Date__c = Date.today(),
            Contract_End_Date__c = Date.today().addYears(1),
            KVA_Rating__c = 100
        );
        insert cli;

        // Set Mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call method
        Test.startTest();
        ContractUnoPoint.SyncContractLineItems(new Set<Id>{cli.Id});
        Test.stopTest();

        // Verify result
        Contract_Line_Item__c updatedCli = [SELECT Sync_Uno_Point__c, Sync_Error_Message__c FROM Contract_Line_Item__c WHERE Id = :cli.Id];
        System.debug('Error Message: ' + updatedCli.Sync_Error_Message__c);
        System.assertEquals(true, updatedCli.Sync_Uno_Point__c, 'Sync_Uno_Point__c should be true');
        System.assertEquals(null, updatedCli.Sync_Error_Message__c, 'Error message should be null');
    }
}