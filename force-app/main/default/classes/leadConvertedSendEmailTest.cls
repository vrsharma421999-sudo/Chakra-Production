@isTest(seealldata=true)
public class leadConvertedSendEmailTest 
{    
    static testMethod void leadTestMethod()
    {
        test.startTest();
        
        List<User> lstu = [Select id,LastName,isActive from User where isActive = true];
        
        Lead lead = new Lead();
        lead.LastName = 'Test lead';
        lead.MobilePhone = '1234';
        lead.Company = 'Test Company';
        lead.Lead_Status__c = 'Qualified';
        lead.Status = 'Open';
        lead.OwnerId = lstu[0].Id;
        insert lead;
        lead.Status = 'Converted';
        update lead;
        
        Database.LeadConvert[] converts = new Database.LeadConvert[0];
        LeadStatus convertedStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        Database.LeadConvert convert = new Database.LeadConvert();
        convert.setLeadId(lead.Id); 
        convert.setConvertedStatus('Converted');
        convert.setOwnerId(lstu[0].Id);
        //convert.setDoNotCreateOpportunity(TRUE);
        converts.add(convert);
        
        
        if(!converts.isEmpty()){
            
            Database.convertLead(converts);
        }
        test.stopTest();
        
    }
}