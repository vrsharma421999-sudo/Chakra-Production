@isTest
public class DealBatch_Test 
{
    static testmethod void OpportunityTestMethod()
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity opp = new Opportunity ();
        opp.name = 'Test Opportunity';
        opp.StageName = 'Approval';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today().addDays(-1);
        opp.OwnerId = '005Do0000023sLf';
        opp.ManagerEmail__c = 'nikkipandeyy.999@gmail.com';
        insert opp;

        Test.startTest();
        
        DealBatchSchedule myClass = new DealBatchSchedule();   
        String chron = '0 0 10 ? * *';        
        system.schedule('Test Sched', chron, myClass);
        Test.stopTest();
    }
    
}