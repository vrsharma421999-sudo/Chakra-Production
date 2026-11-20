@isTest
public class QuoteAssetController_Test {

    @testSetup
    static void setupData() {

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Deal',
            AccountId = acc.Id,
            CloseDate = Date.today(),
            StageName = 'Initial Meeting'
        );
        insert opp;

       // Pricebook2 stdPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
      Id stdPb = Test.getStandardPricebookId();

Pricebook2 pb = new Pricebook2(
    Id = stdPb,
    IsActive = true
);
update pb;

        Product2 prod = new Product2(
            Name = 'Test Product',
            IsActive = true,
            Item_Id__c = 'ITEM-001'
        );
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPb,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        Quote q = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Pricebook2Id = stdPb,
            Status = 'Draft'
        );
        insert q;

        Asset__c asset = new Asset__c(
            Deal__c = opp.Id,
            Product__c = prod.Id,
            RECD_Serial_No__c = 'SER123'
        );
        insert asset;
    }

    /* =============================
       Test getServiceYearOptions
       ============================= */
    @isTest
    static void testServiceYearOptions() {

        Test.startTest();
        List<Map<String,String>> opts =
            QuoteAssetController.getServiceYearOptions();
        Test.stopTest();

        System.assertNotEquals(null, opts);
    }

    /* =============================
       Test getAssets
       ============================= */
    @isTest
    static void testGetAssets() {

        Quote q = [SELECT Id FROM Quote LIMIT 1];

        Test.startTest();
        List<QuoteAssetController.AssetQuoteWrapper> res =
            QuoteAssetController.getAssets(q.Id);
        Test.stopTest();

        System.assert(res.size() > 0);
    }

    /* =============================
       Test saveQuoteLines
       ============================= */
    @isTest
    
static void testSaveQuoteLines_Insert_Update_Delete() {

    Test.getStandardPricebookId();

    Quote q = [SELECT Id FROM Quote LIMIT 1];
    Asset__c asset = [SELECT Id, Product__c FROM Asset__c LIMIT 1];

    QuoteAssetController.AssetQuoteWrapper w =
        new QuoteAssetController.AssetQuoteWrapper();

    w.assetId = asset.Id;
    w.productId = asset.Product__c;
    w.productName = 'Test Product';
    w.quantity = 1;
    w.price = 150;
    w.discount = 10;
    w.selected = true;
    w.service = 'SER123';
    w.serviceYear = '1';

    List<QuoteAssetController.AssetQuoteWrapper> rows =
        new List<QuoteAssetController.AssetQuoteWrapper>{ w };

    Test.startTest();

    // Insert path
    QuoteAssetController.saveQuoteLines(q.Id, rows);

    // Update path
    w.price = 200;
    QuoteAssetController.saveQuoteLines(q.Id, rows);

    // Delete path
    w.selected = false;
    QuoteAssetController.saveQuoteLines(q.Id, rows);

    Test.stopTest();

    List<QuoteLineItem> qliAfterDelete =
        [SELECT Id FROM QuoteLineItem];

    System.assertEquals(0, qliAfterDelete.size());
}
    /* =============================
       Test getAssets with existing QLI
       ============================= */
    @isTest
    static void testGetAssets_WithExistingQLI() {

        Quote q = [SELECT Id, Pricebook2Id FROM Quote LIMIT 1];
        Asset__c asset = [SELECT Id, Product__c FROM Asset__c LIMIT 1];

        PricebookEntry pbe = [
            SELECT Id
            FROM PricebookEntry
            WHERE Product2Id = :asset.Product__c
            LIMIT 1
        ];

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert qli;

        Test.startTest();
        List<QuoteAssetController.AssetQuoteWrapper> res =
            QuoteAssetController.getAssets(q.Id);
        Test.stopTest();

        System.assert(res.size() > 0);
    }

}