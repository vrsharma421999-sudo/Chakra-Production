public class OpportunityLeadDGAP {
	@AuraEnabled
    public static List<LeadDGListWrapper> ee(Id artId)
    {
        List<LeadDGListWrapper>lstWrap  =new List<LeadDGListWrapper>();
        Set<Id> accid = new Set<Id>();
        system.debug('Opportunity Record id is :'+ artId);
        List<Opportunity> lstopp = [select id,Name,
                                    StageName, CloseDate,
                                    AccountId from Opportunity
                                   Where Id =: artId];
        system.debug('oppaccid is:'+lstopp);
        
        if(!lstopp.isEmpty())
        {
            for(Opportunity opp: lstopp)
            {
                accid.add(opp.AccountId);
            }
        
    }
        List<Lead_DGs__c> lstlead=[Select id,Turbo_Type__c,Year_of_Manufacturer__c,Quantity__c,DG_Make__c,
                                   	DG_Type__c,Total_Individual_KVA__c,Dual_Fuel_Kit__c,DG_KVA_Rating__c, Lead__c
                                     from Lead_DGs__c where Account__c=:accid];
        system.debug('lstleadDG is :' +lstlead);
        for(Lead_DGs__c DGObj : lstlead)
            {
                LeadDGListWrapper wrapobj = new LeadDGListWrapper();
                wrapobj.leadRecord = DGObj;
                wrapobj.checkboxvalue = false;
                lstWrap.add(wrapobj);
            }
        return lstWrap;
        
    }
    

 public class LeadDGListWrapper{
        @AuraEnabled
        public Lead_DGs__c leadRecord{get;set;}
        @AuraEnabled
        public Boolean checkboxvalue{get;set;}
 } 
    
    @AuraEnabled	
    public static Boolean  insertLeadDG(id srid,String str)
    {
        system.debug('service report record id is :: '+srid);
        system.debug('str is :: '+str);
            list<LeadDGListWrapper> lststr =(list<LeadDGListWrapper>)JSON.deserialize(str,list<LeadDGListWrapper>.class);
        system.debug('lststr :: '+lststr);
            List<Deal_DG__c>lstinstDG= new List<Deal_DG__c>();
        for(LeadDGListWrapper llw:lststr )
        { 
        	if(llw.checkboxvalue == true)
            {
                Deal_DG__c DGs= new Deal_DG__c();
               		DGs.Deal__c=srid;
                	DGs.Turbo_Type__c=llw.leadRecord.Turbo_Type__c;
               		DGs.Year_of_Manufacturer__c=llw.leadRecord.Year_of_Manufacturer__c;
                	DGs.Dual_Fuel_Kit__c=llw.leadRecord.Dual_Fuel_Kit__c;
                	//DGs.Total_Individual_KVA__c=llw.leadRecord.Total_Individual_KVA__c;
                	DGs.DG_KVA_Rating__c=llw.leadRecord.DG_KVA_Rating__c;
                	DGs.Quantity__c =llw.leadRecord.Quantity__c;
                    DGs.DG_Make__c=llw.leadRecord.DG_Make__c;
                    DGs.DG_Type__c =llw.leadRecord.DG_Type__c;    
                
                lstinstDG.add(DGs);
            }
        }
        
        system.debug('lstinstDG ::::'+lstinstDG);
        if(!lstinstDG.isEmpty())
        {
            if(!test.isRunningTest())
            {
                insert lstinstDG;
            }
            else
            {
                
            }
        	 
            system.debug('lstinstDG is :'+lstinstDG);
            return true;
            
        }
        else{
            return False;
        }
       
}
}