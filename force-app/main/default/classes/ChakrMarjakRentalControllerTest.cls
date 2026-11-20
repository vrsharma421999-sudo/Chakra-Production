@isTest
public class ChakrMarjakRentalControllerTest {

    @isTest
    static void testControllerBranches() {
        // 1. Setup Base Prerequisite Data
        Account acc = new Account(Name = 'Test Account', BillingCountry = 'INDIA');
        insert acc;
        
        Contact con = new Contact(AccountId = acc.Id, LastName = 'test Con', MobilePhone = '9845830933');
        insert con;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acc.Id,
            CloseDate = System.today(),
            StageName = 'PO Released',
            Deal_Amount__c = 5600,
            All_the_stakeholders_identified_and_alig__c = 'Yes',
            Order_Type__c = 'New Business',
            Sales_Consultant_Available__c = 'Not Involved',
            POC_Name__c = con.Id
        );
        insert opp;
        
        Product2 pro2 = new Product2(Name = 'BXCD', isActive = true);
        insert pro2;
        
        Id priceId = Test.getStandardPricebookId();
        PricebookEntry pbe2 = new PricebookEntry(
            UnitPrice = 0.01,
            Product2Id = pro2.Id,
            Pricebook2Id = priceId,
            isActive = true,
            UseStandardPrice = false
        );
        insert pbe2;
        
        Quote q = new Quote(Name = 'test1', OpportunityId = opp.Id, Pricebook2Id = priceId);
        insert q;
        
        QuoteLineItem qitm = new QuoteLineItem(
            QuoteId = q.Id,
            PricebookEntryId = pbe2.Id,
            Product2Id = pro2.Id,
            Quantity = 1,
            UnitPrice = 10000,
            Discount = 10,
            GST_Rate__c = 18,
            OpprotunityRecordType__c = 'Chakr_Marjak',
            Opportunity_BusinessType__c = 'Rental',
            Refundable_Security_Deposit__c = 10000,
            Onboarding_Fee_ex_GST_one_time__c = 5000,
            Monthly_Rental_ex_GST__c = 1000
        );
        insert qitm;

        // 2. Test Execution Block
        Test.startTest();
        
        // Setup Visualforce Page Context
        PageReference testPage = Page.ChakrMarjakRentalProposal; 
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('id', String.valueOf(q.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(q);     
        
        // Instantiate controller to cover initialization code paths
        ChakrMarjakRentalController testCtrl = new ChakrMarjakRentalController(sc);
        
        // --- COVER BRANCH 1: Crore Branch ---
        testCtrl.qliRec = (QuoteLineItem) JSON.deserialize(
            '{"Total_Initial_Commercials_Cost_In_GST__c": 25000000.50, "Refundable_Security_Deposit__c": 10000, "Onboarding_Fee_ex_GST_one_time__c": 5000}', 
            QuoteLineItem.class
        );
        String croreText = testCtrl.getCustomerPitchAmount();
        System.assert(croreText.contains('crore'), 'Should return amount formatted in crores.');

        // --- COVER BRANCH 2: Lakh Branch ---
        testCtrl.qliRec = (QuoteLineItem) JSON.deserialize(
            '{"Total_Initial_Commercials_Cost_In_GST__c": 350000.00}', 
            QuoteLineItem.class
        );
        String lakhText = testCtrl.getCustomerPitchAmount();
        System.assert(lakhText.contains('lakh'), 'Should return amount formatted in lakhs.');

        // --- COVER BRANCH 3: Thousand Branch ---
        testCtrl.qliRec = (QuoteLineItem) JSON.deserialize(
            '{"Total_Initial_Commercials_Cost_In_GST__c": 8500.00}', 
            QuoteLineItem.class
        );
        String thousandText = testCtrl.getCustomerPitchAmount();
        System.assert(thousandText.contains('thousand'), 'Should return amount formatted in thousands.');

        // --- COVER BRANCH 4: Raw Decimal Branch (< 1000) ---
        testCtrl.qliRec = (QuoteLineItem) JSON.deserialize(
            '{"Total_Initial_Commercials_Cost_In_GST__c": 450.00}', 
            QuoteLineItem.class
        );
        String rawText = testCtrl.getCustomerPitchAmount();
        System.assertEquals('450.0', rawText, 'Should return exact decimal string for amounts under a thousand.');

        // --- COVER BRANCH 5: Null / Empty Branch ---
        testCtrl.qliRec = new QuoteLineItem();
        String nullText = testCtrl.getCustomerPitchAmount();
        System.assertEquals('', nullText, 'Should return empty string if target amount evaluated to null.');
        
        Test.stopTest();
    }

    @isTest
    static void testControllerWithEmptyLineItems() {
        // Test scenario where quote query returns no items to cover the 'else' code paths
        Account acc = new Account(Name = 'Empty Test Account'); insert acc;
        Opportunity opp = new Opportunity(Name = 'Empty Opp', StageName = 'Prospecting', CloseDate = System.today(), AccountId = acc.Id); insert opp;
        Quote q = new Quote(Name = 'testEmpty', OpportunityId = opp.Id); insert q;

        ApexPages.currentPage().getParameters().put('id', String.valueOf(q.Id));
        
        Test.startTest();
        ChakrMarjakRentalController testCtrl = new ChakrMarjakRentalController(new ApexPages.StandardController(q));
        Test.stopTest();

        System.assertEquals(0, testCtrl.strvalue, 'strvalue field parameter should fall back to 0 when line item collection is missing.');
    }
}