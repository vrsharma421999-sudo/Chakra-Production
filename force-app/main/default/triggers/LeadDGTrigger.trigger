trigger LeadDGTrigger on Lead_DGs__c (before insert, before update) 
{
  for(Lead_DGs__c LD:trigger.new)
  {
	if (LD.DG_KVA_Rating__c !=null)
    {
        if(!test.isrunningtest()){
        	LD.KVA_Picklist__c = String.valueof(LD.DG_KVA_Rating__c);
        }
    }
  }
}