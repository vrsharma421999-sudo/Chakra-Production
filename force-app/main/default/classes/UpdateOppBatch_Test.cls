@isTest
public class UpdateOppBatch_Test {
    static testMethod void test()
    {               
        Account acc = new Account();
        acc.name = 'test acc';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name='test opp';
        opp.AccountId=acc.Id;
        opp.StageName='Send for Quote Generation';
        opp.CloseDate=system.today();
        insert opp;
        
        Product2 pro2 = new Product2(Name='Test',isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 = new PricebookEntry(unitprice=0.01,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                 isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        Quote q = new Quote();
        q.name='test quote';
        q.OpportunityId=opp.Id;
        insert q;
        
        test.startTest();
        UpdateOppBatch c = new UpdateOppBatch();
        Database.executeBatch(c,1);
        
        UpdateOppBatchSchedule batch = new UpdateOppBatchSchedule();
        String sch = '0 0 * * * ? ';
        String jobIDNew = system.schedule('Appraisa007', sch, batch);
        test.stopTest();
    }
}