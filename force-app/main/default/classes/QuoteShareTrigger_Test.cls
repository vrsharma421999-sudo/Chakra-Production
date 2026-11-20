@isTest (seealldata = true)
public class QuoteShareTrigger_Test {
    
    static testmethod void setup() {
        List<User> lstu =[Select id from User where isActive = true and profileid = '00eDo000001Uacb' limit 2];
        
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today(),
            OwnerId = lstu[0].iD
        );
        insert testOpp;
        
        // Create a test quote
        Test.starttest();
        Quote testQuote = new Quote(
            Name = 'test',
            OpportunityId =testOpp.id ,
            OwnerId = lstu[1].Id
        );
        insert testQuote;
        test.stoptest();
    }
}