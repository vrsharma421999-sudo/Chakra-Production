@isTest
public class GenerateQuoteHandler_Test {
    static TestMethod void test()
    {    
      
   Pricebook2 standardPricebook = new Pricebook2(
    Id = Test.getStandardPricebookId(),
    IsActive = true
);
Update standardPricebook;
      Product2 pro2 = new Product2(Name='test product', isActive=true,type__c = 'Chakr Marjak');
        insert pro2;
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;  
        
         Product2 pro3 = new Product2(Name='Installation Charge', isActive=true);
        insert pro3;
        PricebookEntry pbe3 =new PricebookEntry(unitprice=0.01,Product2Id=pro3.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe3;  
        
        Product2 pro4 = new Product2(Name='AMC Charge', isActive=true);
        insert pro4;
        PricebookEntry pbe4 =new PricebookEntry(unitprice=0.01,Product2Id=pro4.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe4;  
        
         Product2 pro5 = new Product2(Name='Transportation Charge', isActive=true);
        insert pro5;
        PricebookEntry pbe5 =new PricebookEntry(unitprice=0.01,Product2Id=pro5.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe5;  
        
        Account Acc= new Account();
        Acc.Name='Test Account';
        Acc.BillingCountry='INDIA';
        Acc.BillingState='DL';
        Acc.BillingCity='efg';
        insert Acc;
        
        Id oppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Chakr Marjak').getRecordTypeId();   // Use the Record Type LABEL



Opportunity opp = new Opportunity(
    AccountId = acc.Id,
    Name = 'Chakr Test',
    StageName = 'Proposal',
    CloseDate = System.today(),
    RecordTypeId = oppRtId,
    Business_Type__c = 'Rental'
);
insert opp;
        
        Deal_DG__c dg = new Deal_DG__c(
    Deal__c = opp.Id,
    Product__c = pro2.Id,
    Quantity__c = 5,
    Sales_Price__c = 200,
    Monthly_Rental_ex_GST__c = 100,
    Onboarding_Fee_ex_GST_one_time__c = 50,
    Refundable_Security_Deposit__c = 500,
    Minimum_Lock_in_Period__c = '12 Months',
    Maintenance__c = 'Included',
    Buyout_Option_post_lock_in__c = 'Yes',
    Late_Payment_Charge__c = '100/day',
    Reactivation_Charge_post_lock__c = '500',
    Consumables__c = 'Included',
    Freight__c = 'Free',
    Upfront_Saving_vs_Purchase__c = 1000
);
insert dg;
        
        Price_Matrix__c pm = new Price_Matrix__c();
        pm.KVA__c = 125;
        pm.List_Price__c=200;
        pm.Product__c = pro2.Id;
        insert pm;
        system.debug('dg test class '+dg);
        

        test.startTest();
        GenerateQuoteHandler.getDealDG(opp.Id);
        GenerateQuoteHandler.calculateQuote(opp.Id);
       // MyException  e = new MyException ();
		//e.addError('Error', false);
        test.stopTest();
        
    }
    @isTest
static void testCalculateQuote_NonChakrMarjak()
{
    // Standard Pricebook
    Pricebook2 stdPb = new Pricebook2(
        Id = Test.getStandardPricebookId(),
        IsActive = true
    );
    update stdPb;

    // Product
    Product2 prod = new Product2(
        Name = 'Test Product',
        IsActive = true
    );
    insert prod;

    PricebookEntry pbe = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(),
        Product2Id = prod.Id,
        UnitPrice = 200,
        IsActive = true,
        UseStandardPrice = false
    );
    insert pbe;

    // Account
    Account acc = new Account(
        Name='Test Account',
        BillingCountry='India'
    );
    insert acc;

    // ************ IMPORTANT ************
    // NON Chakr Marjak Record Type
    Id oppRtId = Schema.SObjectType.Opportunity
        .getRecordTypeInfosByDeveloperName()
        .get('AMC')       // <-- Change if required
        .getRecordTypeId();

    Opportunity opp = new Opportunity(
        Name='Normal Opportunity',
        AccountId=acc.Id,
        StageName='Proposal',
        CloseDate=System.today(),
        RecordTypeId=oppRtId,
        Chakr_Shield_Model__c='M1',
        Transportation__c='Yes',
        Installation__c='Yes',
        AMC__c='1yr'
    );
    insert opp;

    Deal_DG__c dg = new Deal_DG__c(
        Deal__c=opp.Id,
        DG_KVA_Rating__c=125,
        Quantity__c=5
    );
    insert dg;

    Price_Matrix__c pm = new Price_Matrix__c(
        KVA__c=125,
        Product__c=prod.Id,
        List_Price__c=250
    );
    insert pm;

    Test.startTest();

    String result = GenerateQuoteHandler.calculateQuote(opp.Id);

    Test.stopTest();

    System.assertNotEquals(null, result);

    List<QuoteLineItem> qlis = [
        SELECT Id,
               Quantity,
               UnitPrice,
               Matrix_List_Price__c,
               Description
        FROM QuoteLineItem
    ];

    System.assertEquals(1, qlis.size());
}


}