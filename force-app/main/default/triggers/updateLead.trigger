trigger updateLead on Lead_DGs__c (after insert , after update) 
{
	if((trigger.isInsert && trigger.isafter) || (trigger.isafter && trigger.isUpdate))
	{
        system.debug('inside lead dg trigger ');
		Set<Id> idset = new Set<Id>();
      	list <lead> lstlead = new list<lead>();
        
        
        
      	for( Lead_DGs__c ld : Trigger.new)
        {
            if(ld.Lead__c!=null){
            
            system.debug(ld.lead__c);
            if(ld.Quantity__c != null )
            {
                idset.add(ld.Lead__c);
            }
            
      	}
        System.debug('id is'+idset);
        if(!idset.isEmpty())
        {
        List<Lead_DGs__c> DGlist = [SELECT Id, Quantity__c,Lead__c FROM Lead_DGs__c WHERE Lead__c in : idset];
        System.debug( 'list of dg'+ DGlist);
        decimal totalqty = 0;
        if(!DGlist.isEmpty())
        {
            for(Lead_DGs__c DG : DGlist)
            {
               totalqty = totalqty + dg.Quantity__c;
            }
            system.debug('inside if');   
          lead l = new lead();
          for (id id1 : idset)
          l.id = id1;
          l.No_of_DGs__c = totalqty;
          system.debug('l value is '+l);  
          if(l.IsConverted == false)
          {
              update l; 
          }
        }
    }
   }
  }
}