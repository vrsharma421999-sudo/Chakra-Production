@istest
public class LeadDGTriggerTest {
    
    public static testmethod void testmethod1()
    {
        test.starttest();
        Lead LD=new Lead();
        LD.LastName='Muskan';
        LD.Company='Company';
        LD.MobilePhone='1';
        LD.Channel__c='Channel';
        LD.Source__c='Source';
        LD.DG__c='Yes';
        insert ld;
        
        
        Lead_DGs__c	LDs=new Lead_DGs__c();
        LDs.Quantity__c=1;
        LDs.DG_KVA_Rating__c=1;
        lds.Lead__c = ld.id;
        LDs.DG_Type__c='CPCB1 (August 2014 - July 2023)';
        LDs.Year_of_Manufacturer__c='1111';
        Insert LDs;
        test.stoptest();
    }

}