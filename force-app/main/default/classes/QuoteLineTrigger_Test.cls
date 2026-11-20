@isTest
public class QuoteLineTrigger_Test {
    public static testmethod void test_M1(){
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'test Con';
        con.MobilePhone = '98458309';
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'PO Released';
        opp.Deal_Amount__c = 5600;
        opp.All_the_stakeholders_identified_and_alig__c = 'Yes';
        opp.Order_Type__c = 'New Business';
        opp.Sales_Consultant_Available__c = 'Not Involved';
        opp.POC_Name__c = con.Id;
        insert opp;

        String prID2 = Test.getStandardPricebookId();
        
        Quote qt = new Quote();
        qt.Pricebook2Id = prID2;
        qt.OpportunityId = opp.Id;
        qt.Name = 'test Qt';
        //qt.Terms_And_Conditions__c = 'test';
        insert qt;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'test PriceBook';
        //pb.IsStandard = true;
        pb.Description = 'test';
        pb.IsActive = true;
        insert pb;
        
        //Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        
        Product2 product = new Product2();
            product.Name = 'Test Product';
            product.Family = 'Test Family';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = prID2;
            pbe.Product2Id = product.Id;            
            pbe.UnitPrice = 100.0;
        //pbe.UseStandardPrice = true;
            pbe.IsActive = true; 
        insert pbe;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.Product2Id = product.Id;
        qli.PricebookEntryId = pbe.Id;
        //qli.QuoteId = '0Q0Rt000000IMdBKAW';
        qli.QuoteId = qt.Id;
        qli.UnitPrice = 500;
        qli.Quantity = 5;
        qli.GST_Rate__c = 18;
        insert qli;
        
        qli.Quantity = 6;
        update qli;
		 Test.stopTest();
    }
}