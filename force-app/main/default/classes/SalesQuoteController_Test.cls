@isTest
public class SalesQuoteController_Test {
    
    static testMethod void insertNewOpportunity() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'INDIA';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'test Con';
        con.MobilePhone = '9845830944';
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
        
        Product2 pro2 = new Product2(
            Name = 'BXCD',
            isActive = true);
        insert pro2;
        
        PricebookEntry pbe2 = new PricebookEntry(
            unitprice = 0.01,
            Product2Id = pro2.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            isActive = true,
            UseStandardPrice = false);
        insert pbe2;
        Id priceId = Test.getStandardPricebookId();
        Quote q = new Quote();
        q.Name = 'test1';
        q.OpportunityId = opp.Id;
        q.pricebook2id = priceId;
        insert q;
        
        QuoteLineItem qitm = NEW QuoteLineItem();        
        qitm.Description = 'test';
        qitm.QuoteId = q.Id;
        qitm.PricebookEntryId = pbe2.Id;
        qitm.Discount = 10;
        //qitm.GST_Amount_1__c = 10;
        qitm.GST_Rate__c = 5;
        qitm.Quantity = 1.0;
        qitm.UnitPrice = 1.0;
        qitm.Product2Id = pro2.Id;
        insert qitm;
        
        system.debug('q is '+q);
        system.debug('qitm is '+qitm);
        
        test.startTest();
        PageReference testPage = Page.SalesQuotation; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(q.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(q);     
        SalesQuoteController testAccPlan = new SalesQuoteController(sc);
        SalesQuotationAuraController.createQuoteDocument(q.id,true);
        test.stopTest();
        
        
        /*ApexPages.StandardController sc = new ApexPages.StandardController(q);
		PageReference pageRef = Page.SalesQuotation; // Add your VF page Name here
		pageRef.getParameters().put('id', String.valueOf(q.Id));
		SalesQuoteController testAccPlan = new SalesQuoteController(sc);
		Test.setCurrentPage(pageRef);  */     
    }
}