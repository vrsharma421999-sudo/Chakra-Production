@isTest
private class AccountTriggerHandlerTest {
    
    @testSetup
    static void setupData() {
        // Create Parent Account
        Account parentAcc = new Account(
            Name = 'Parent Account'
        );
        insert parentAcc;

        // Create 2 Child Accounts under Parent
        List<Account> childAccounts = new List<Account>{
            new Account(Name = 'Child Account 1', ParentId = parentAcc.Id),
            new Account(Name = 'Child Account 2', ParentId = parentAcc.Id)
        };
        insert childAccounts;

        // Create Opportunities under each child to roll up Acc_Business_Potential__c
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Opp 1 - Child 1', StageName = 'Closed Won', CloseDate = Date.today(), Amount = 1000, AccountId = childAccounts[0].Id),
            new Opportunity(Name = 'Opp 2 - Child 1', StageName = 'Closed Won', CloseDate = Date.today(), Amount = 500,  AccountId = childAccounts[0].Id),
            new Opportunity(Name = 'Opp 1 - Child 2', StageName = 'Closed Won', CloseDate = Date.today(), Amount = 700,  AccountId = childAccounts[1].Id)
        };
        insert opps;

        // Let roll-up summary fields calculate
        Test.startTest();
        Test.stopTest();
    }
    
    @isTest
    static void testHandleAcc_WhenParentChanged() {
        // Create a new parent to simulate re-parenting
        Account newParent = new Account(Name = 'New Parent Account');
        insert newParent;

        // Get one child and re-parent it
        Account child = [SELECT Id, ParentId FROM Account WHERE ParentId != NULL LIMIT 1];
        child.ParentId = newParent.Id;

        Test.startTest();
        update child;
        Test.stopTest();

        // Verify that the new parent got updated
        Account newParentAfter = [SELECT Id, Child_Account_Business_Potential__c FROM Account WHERE Id = :newParent.Id];
        System.assertNotEquals(null, newParentAfter.Child_Account_Business_Potential__c, 
            'New Parent should have its Child_Account_Business_Potential__c updated.');
    }
}