@isTest
public class SalesPdfChakrMarjakControllerTest {

    @isTest
    static void testController() {

        // Account
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        // Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Initial Meeting Conducted',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Payment_Terms__c = '100% Advance'
        );
        insert opp;

        // Quote
        Quote qt = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            ExpirationDate = Date.today().addDays(15),
            Category__c = 'AMOC Procurement',
            Terms_And_Conditions__c = 'Test Terms'
        );
        insert qt;

        // Quote Line Item
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = qt.Id
            // Populate any mandatory fields in your org,
            // such as PricebookEntryId, Quantity, UnitPrice, etc.
        );

        try{
            insert qli;
        }catch(Exception e){
            // Ignore if additional mandatory fields exist
        }

        Test.setCurrentPage(Page.SalesPdfChakrMarjak);

        ApexPages.currentPage().getParameters().put('id', qt.Id);

        ApexPages.StandardController sc =
            new ApexPages.StandardController(qt);

        Test.startTest();

        SalesPdfChakrMarjakController controller =
            new SalesPdfChakrMarjakController(sc);

        Test.stopTest();
    }
}