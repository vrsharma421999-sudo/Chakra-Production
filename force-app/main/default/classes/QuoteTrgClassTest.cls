@isTest
public class QuoteTrgClassTest {
    static testmethod void t1(){
        test.startTest();
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
        //q.TotalPrice = 100;
        insert q;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.UnitPrice = 500;
        
        test.stopTest();
    }

        @isTest
    static void testSupplierAddressPopulation() {
        Account acc = new Account(Name = 'Supplier Test Acc');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'AMC Opp Test',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        
        // Test Plant Default Insertion
        Quote q = new Quote(Name = 'Plant Quote', OpportunityId = opp.Id);
        insert q;
        
        Quote qInserted = [SELECT Supplier_Address_Option__c, Supplier_Company_Name__c, Supplier_GSTIN__c FROM Quote WHERE Id = :q.Id];
        System.assertEquals('Gurugram Plant', qInserted.Supplier_Address_Option__c);
        System.assertEquals('Chakr Innovation Private Limited - Gurugram Plant', qInserted.Supplier_Company_Name__c);
        System.assertEquals('06AAGCC5131K1ZR', qInserted.Supplier_GSTIN__c);
        
        // Test Update to HO
        q.Supplier_Address_Option__c = 'Gurugram HO';
        update q;
        
        Quote qUpdated = [SELECT Supplier_Address_Option__c, Supplier_Company_Name__c FROM Quote WHERE Id = :q.Id];
        System.assertEquals('Gurugram HO', qUpdated.Supplier_Address_Option__c);
        System.assertEquals('Chakr Innovation Private Limited - Gurugram HO', qUpdated.Supplier_Company_Name__c);
    }

}