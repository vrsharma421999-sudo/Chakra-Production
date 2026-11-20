@isTest
public class LeadTrigger_Test 
{
    static testmethod void test() 
    {
        Id leadRtId = Schema.SObjectType.Lead
    .getRecordTypeInfosByDeveloperName()
    .get('RECD_ECB')
    .getRecordTypeId();
        Test.startTest();
        Lead lead = new Lead();
        lead.RecordTypeId = leadRtId;
        lead.FirstName = 'Trigger1';
        lead.LastName = 'Test1';
        lead.Company = 'Trigger Test1';
        lead.LeadSource = 'Web';
        lead.Status = 'Lead Status';
        lead.Lead_Status__c = 'Qualified';
      //  lead.OwnerId = '005Do000002cd2U';
        //lead.Address = 'test'; 
        lead.Calling_Status__c = 'Answered - Discussion Completed';
        lead.Qualified_Status__c ='Follow-Up Required';
        insert lead; 
        lead.Status='Converted'; 
        
        
        lead.Lead_Status__c = 'Qualified';
        update lead;
        Lead_DGs__c ldg = new Lead_DGs__c();
        ldg.Lead__c = lead.Id;
        ldg.Year_of_Manufacturer__c = '2023';
        ldg.DG_Make__c = '';
        ldg.DG_KVA_Rating__c = null;
        //ldg.Opportunity__c = opp.Id;
        ldg.Quantity__c = 1;
        insert ldg;        
        ldg.Quantity__c = 5;
        update ldg;
        
      //  System.AssertEquals (1, [Select Id,FirstName from Lead where Status='Open' and  id=:lead.id].size());
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
    }
    static testmethod void test1() 
    {
        Id leadRtId = Schema.SObjectType.Lead
    .getRecordTypeInfosByDeveloperName()
    .get('RECD_ECB')
    .getRecordTypeId();
        Test.startTest();
        Lead lead = new Lead();
        lead.RecordTypeId = leadRtId;
        lead.FirstName = 'Trigger1';
        lead.LastName = 'Test1';
        lead.Company = 'Trigger Test1';
        lead.LeadSource = 'Web';
        lead.Status='Open'; 
        lead.Country='India';
        lead.State = 'AN';
       // lead.StateCode='GA'; 
        insert lead; 
        lead.Status='Assigned';
        update lead;
        lead.Status='Calling';
        lead.Calling_Status__c = 'Answered - Discussion Completed';
        update lead;
        
        lead.Lead_Status__c = 'Qualified'; 
        lead.Qualified_Status__c = 'Follow-Up Required';
        lead.Status = 'Lead Status';
        lead.DG__c = 'Yes';
        update lead;
        Lead_DGs__c ldg = new Lead_DGs__c();
        ldg.Lead__c = lead.Id;
        ldg.Year_of_Manufacturer__c = '2024';
        ldg.DG_Make__c = 'Mahindra';
        ldg.DG_KVA_Rating__c = 9;
        //ldg.Opportunity__c = opp.Id;
        ldg.Quantity__c = 1;
        insert ldg;        
        ldg.Quantity__c = 5;
        update ldg;
        
        test.stoptest();
    }
}