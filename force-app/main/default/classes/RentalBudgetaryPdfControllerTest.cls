@isTest
private class RentalBudgetaryPdfControllerTest {

    @isTest
    static void testControllerWithLineItemAndAllAmountBranches() {
        // 1. Create Prerequisite Setup Data
        Account acc = new Account(Name = 'Test Rail Depot Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Rail Opp',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(10),
            AccountId = acc.Id
        );
        insert opp;

        Product2 prod = new Product2(
            Name = 'Chakr Marjak Machine',
            IsActive = true
        );
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 10000.0,
            IsActive = true
        );
        insert pbe;

        Quote qRec = new Quote(
            Name = 'Test Budgetary Quotation',
            OpportunityId = opp.Id,
            Pricebook2Id = pricebookId,
            Comprehensive_Maintenance__c = 5000,
            Digital_Monitoring_App__c = 4000,
            Dedicated_Relationship_Mgr__c = 2000,
            Valid_for__c = '15 Days',
            Delivery__c = '4 Weeks'
        );
        insert qRec;

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = qRec.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 10000.0,
            Refundable_Security_Deposit__c = 50000.0,
            Onboarding_Fee_ex_GST_one_time__c = 25000.0,
            Monthly_Rental_ex_GST__c = 45000.0,
            Minimum_Lock_in_Period__c = '12 Months',
            Maintenance__c = 'Included',
            Late_Payment_Charge__c = '2% per month',
            Consumables__c = 'Excluded',
            Buyout_Option_post_lock_in__c = 'Available',
            Reactivation_Charge_post_lock__c = '15000',
            Freight__c = 'At Actuals',
            Upfront_Saving_vs_Purchase__c = 120000.0
        );
        insert qli;

        // 2. Set Visualforce Page context parameters
        PageReference pageRef = Page.RentalBudgetaryPdf; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', qRec.Id);

        // 3. Execute Controller Initialization
        ApexPages.StandardController stdController = new ApexPages.StandardController(qRec);
        
        Test.startTest();
        RentalBudgetaryPdfController controller = new RentalBudgetaryPdfController(stdController);
        
        // --- COVER CRORE BRANCH ---
        // We use JSON.deserialize to inject values directly into read-only formula fields
        controller.qliRec = (QuoteLineItem) JSON.deserialize(
            '{"Total_Initial_Commercials_Cost_In_GST__c": 25000000.50, "Refundable_Security_Deposit__c": 50000.0, "Onboarding_Fee_ex_GST_one_time__c": 25000.0}', 
            QuoteLineItem.class
        );
        String pitchAmountCrore = controller.getCustomerPitchAmount();
        System.assert(pitchAmountCrore.contains('crore'), 'Pitch amount should format into crores.');
        
        // --- COVER LAKH BRANCH ---
        controller.qliRec = (QuoteLineItem) JSON.deserialize(
            '{"Total_Initial_Commercials_Cost_In_GST__c": 350000.00}', 
            QuoteLineItem.class
        );
        String pitchAmountLakh = controller.getCustomerPitchAmount();
        System.assert(pitchAmountLakh.contains('lakh'), 'Pitch amount should format into lakhs.');

        // --- COVER THOUSAND BRANCH ---
        controller.qliRec = (QuoteLineItem) JSON.deserialize(
            '{"Total_Initial_Commercials_Cost_In_GST__c": 8500.00}', 
            QuoteLineItem.class
        );
        String pitchAmountThousand = controller.getCustomerPitchAmount();
        System.assert(pitchAmountThousand.contains('thousand'), 'Pitch amount should format into thousands.');

        // --- COVER RAW DECIMAL BRANCH (< 1000) ---
        controller.qliRec = (QuoteLineItem) JSON.deserialize(
            '{"Total_Initial_Commercials_Cost_In_GST__c": 450.00}', 
            QuoteLineItem.class
        );
        String pitchAmountRaw = controller.getCustomerPitchAmount();
        System.assertEquals('450.0', pitchAmountRaw, 'Pitch amount should return raw string value.');
        
        // --- COVER NULL AMOUNT BRANCH ---
        controller.qliRec = new QuoteLineItem(); // Total_Initial_Commercials_Cost_In_GST__c will be null
        String pitchAmountNull = controller.getCustomerPitchAmount();
        System.assertEquals('', pitchAmountNull, 'Should return empty string if value is null.');

        Test.stopTest();

        // Base field assertions
        System.assertNotEquals(null, controller.quoteRec, 'Quote record should be queried successfully.');
        System.assertNotEquals(null, controller.quoteOwner, 'Quote owner user details should be queried successfully.');
    }

    @isTest
    static void testEmptyLineItemGracefulDegradation() {
        // Verify code behaves cleanly when a Quote contains no attached line items (Covers the 'else' block in constructor)
        Account acc = new Account(Name = 'Empty Line Account'); 
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Empty Line Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.Id); 
        insert opp;
        
        Quote qRec = new Quote(Name = 'Empty Quote', OpportunityId = opp.Id); 
        insert qRec;

        ApexPages.currentPage().getParameters().put('id', qRec.Id);
        
        Test.startTest();
        RentalBudgetaryPdfController controller = new RentalBudgetaryPdfController(new ApexPages.StandardController(qRec));
        String emptyAmount = controller.getCustomerPitchAmount();
        Test.stopTest();

        System.assertEquals(0, controller.strvalue, 'strvalue initialization default fallback must equate to 0 if list scope is empty.');
        System.assertEquals('', emptyAmount, 'If line record components evaluate to null parameters, return string should pass empty values safely.');
    }
}