@istest
public class updateLead_Test1 {
static testmethod void test() 
    {
        Test.startTest();
        lead l = new lead();
        l.firstname = 'test';
        l.LastName = 'test';
        l.Company = 'test company';
        l.MobilePhone='9857575345';
        l.Channel__c='Marketing';
        l.DG__c='Yes';
        l.Source__c='Paid';
        insert l;
        Lead_DGs__c dg = new Lead_DGs__c();
        dg.Lead__c = l.id;
        dg.Quantity__c = 10;
        insert dg;
        Test.stopTest();
    }
}