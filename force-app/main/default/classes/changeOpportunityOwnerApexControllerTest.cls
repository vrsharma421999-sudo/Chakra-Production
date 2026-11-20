@isTest
public class changeOpportunityOwnerApexControllerTest {
    @TestSetup
    static void setupTestData() {
        // Create test profiles
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create active test users
        /*List<User> testUsers = new List<User>();
        for (Integer i = 1; i <= 3; i++) {
            User testUser = new User(
                FirstName = 'Test',
                LastName = 'User' + i,
                Email = 'testuser' + i + '@test.com',
                Username = 'testuser' + i + '@test.com.test',
                Alias = 'tuser' + i,
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = standardProfile.Id,
                LanguageLocaleKey = 'en_US',
                IsActive = true
            );
            testUsers.add(testUser);
        }
        
        User inactiveUser = new User(
            FirstName = 'Inactive',
            LastName = 'User',
            Email = 'inactiveuser@test.com',
            Username = 'inactiveuser@test.com.test',
            Alias = 'iuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = false
        );
        testUsers.add(inactiveUser);
        
        insert testUsers;*/
        
        // Create test account
        Account testAccount = new Account(
            RecordTypeId = '012Do0000004ljlIAA',
            Name = 'Test Account',
            Type = 'Prospect',
            Industry = 'Technology',
            Phone = '9834938',
            Primary_POC_Email__c = 'test@gmail.com',
            Central_Contract__c = 'Yes'
        );
        insert testAccount;
        
        // Create test contact
        Contact con = new Contact(
            LastName = 'LastCon',
            MobilePhone = '98498334',
            AccountId = testAccount.Id
        );
        insert con;
        
        // Create test opportunity with AccountId
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = '012Do0000004ljvIAA',
            POC_Name__c = con.Id,
            Country__c = 'India',
            Region__c = 'North',
            Order_Type__c = 'New Business',
            Sales_Consultant_Available__c = 'Involved',
            City__c = 'Noida',
            State__c = 'Bihar',
            Name = 'Test Opportunity',
            AccountId = testAccount.Id
            //Amount = 10000,
            //CloseDate = Date.today().addDays(30),
            //StageName = 'Prospecting',
            //OwnerId = testUsers[0].Id
        );
        insert testOpportunity;
        Id userID = '005Do0000023sLf';
        Id Inactive = '005Do000001Uthi';
        
        Test.startTest();
        Map<String, Object> result = changeOpportunityOwnerApexController.updateOpportunityOwner(
            testOpportunity.Id, 
            userID
        );
        Map<String, Object> result1 = changeOpportunityOwnerApexController.updateOpportunityOwner(
            null, 
            userID
        );
        Map<String, Object> result2 = changeOpportunityOwnerApexController.updateOpportunityOwner(
            testOpportunity.Id, 
            Null
        );
        Map<String, Object> result3 = changeOpportunityOwnerApexController.updateOpportunityOwner(
            testOpportunity.Id, 
            Inactive
        );
        
        Id fakeOpportunityId = '006000000000000AAA';
        Map<String, Object> result4 = changeOpportunityOwnerApexController.updateOpportunityOwner(
            fakeOpportunityId, 
            Inactive
        );
        Id fakeUserId = '005000000000000AAA';
        Map<String, Object> result5 = changeOpportunityOwnerApexController.updateOpportunityOwner(
            testOpportunity.Id, 
            fakeUserId
        );
        Test.stopTest();
    }
    
    @isTest
    static void testGetActiveUsers_Success() {
        Test.startTest();
        List<User> activeUsers = changeOpportunityOwnerApexController.getActiveUsers();
        Test.stopTest();
    }
}