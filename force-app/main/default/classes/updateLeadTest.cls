@isTest
private class updateLeadTest {
    static testmethod void test(){
        Test.startTest();
        Lead l = new Lead();
        l.LastName = 'test';
        l.Company = 'testing';
        l.Status = 'open';
        l.No_of_DGs__c = 2;
        insert l;
        
        Lead_DGs__c lDG = new Lead_DGs__c();
        lDG.Quantity__c = 5;
        lDG.Lead__c = l.Id;
        insert lDG;
        
        test.stopTest();
    }
}