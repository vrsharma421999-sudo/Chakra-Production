@istest
public class updateLead_Test {
static testmethod void test() 
    {
        Test.startTest();
        lead l = new lead();
        l.firstname = 'test';
        l.LastName = 'test';
        l.Company = 'test company';
        insert l;
        Lead_DGs__c dg = new Lead_DGs__c();
        dg.Lead__c = l.id;
        dg.Quantity__c = 10;
        insert dg;
        Test.stopTest();
    }
}