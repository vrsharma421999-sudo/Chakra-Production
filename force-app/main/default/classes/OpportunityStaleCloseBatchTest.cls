@isTest
public class OpportunityStaleCloseBatchTest {
   
    @testSetup
    static void setup() {
        List<Opportunity> oppList = new List<Opportunity>();
       account acc = new account();
        acc.name = 'test';
        insert acc;
        for(Integer i = 0; i < 10; i++) {
            Opportunity opp = new Opportunity();
            opp.accountId = acc.id;
            opp.Name = 'Test Opp ' + i;
            opp.StageName = 'Prospecting';
            opp.CloseDate = Date.today().addDays(30);
            oppList.add(opp);
        }
        insert oppList;
       
        // Update to set LastModifiedDate in past
        Test.setCreatedDate(oppList[0].Id, Date.today().addDays(-100));
    }
   
    @isTest
    static void testBatch() {
        Test.startTest();
        OpportunityStaleCloseBatch batch = new OpportunityStaleCloseBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }
   
    @isTest
    static void testScheduler() {
        Test.startTest();
        String cronExp = '0 0 0 * * ?';
        String jobId = System.schedule('Test Stale Opp Closer', cronExp, new OpportunityStaleCloseScheduler());
        Test.stopTest();
    }
}