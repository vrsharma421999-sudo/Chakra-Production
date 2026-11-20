@isTest
public class changeOwnerApexControllerTest {
    @TestSetup
    static void setupTestData() {
        // Create test profiles
        /*Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create active test users
        List<User> testUsers = new List<User>();
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
        
        // Create one inactive user
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
        
        // Create test opportunity
        Account testOpportunity = new Account(
            Name = 'Test Opportunity'
            /*Amount = 10000,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',*/
            //OwnerId = testUsers[0].Id
        );
        insert testOpportunity;
        
        Id userID = '005Do0000023sLf';
        Id Inactive = '005Do000001Uthi';
        
        Map<String, Object> result = changeOwnerApexController.updateOpportunityOwner(
            testOpportunity.Id, 
            userID
        );
        Map<String, Object> result1 = changeOwnerApexController.updateOpportunityOwner(
            null, 
            userID
        );
        Map<String, Object> result2 = changeOwnerApexController.updateOpportunityOwner(
            testOpportunity.Id, 
            null
        );
        Id fakeOpportunityId = '006000000000000AAA';
        Map<String, Object> result3 = changeOwnerApexController.updateOpportunityOwner(
            fakeOpportunityId, 
            userID
        );
        Id fakeUserId = '005000000000000AAA';
        Test.startTest();
        Map<String, Object> result4 = changeOwnerApexController.updateOpportunityOwner(
            testOpportunity.Id, 
            fakeUserId
        );
        Map<String, Object> result5 = changeOwnerApexController.updateOpportunityOwner(
            testOpportunity.Id, 
            Inactive
        );
        Map<String, Object> result6 = changeOwnerApexController.updateOpportunityOwner(
            testOpportunity.Id, 
            userID
        );
        
    }
    @isTest
    static void testGetActiveUsers_Success() {
        Test.startTest();
        List<User> activeUsers = changeOwnerApexController.getActiveUsers();
        Test.stopTest();
    }
}