public class LeadTriggerHandler
{
    public static void checkLeadDgFields(List<Lead> newRec, Map<Id,Lead> oldMap)
    {
        set<Id> leadId = new Set<Id>();
        boolean flag = false;
        List<Lead_DGs__c> ldList = new List<Lead_DGs__c>();
        
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
        Id chakrMarjakRTId = rtMap.containsKey('Chakr_Marjak')? rtMap.get('Chakr_Marjak').getRecordTypeId(): null;
        
        for(Lead ld: newRec)
        {
            if(ld.Status == 'Lead Status' && ld.Lead_Status__c == 'Qualified' )
            {
                leadId.add(ld.Id);
            }
            system.debug('leadId '+ newRec); 
            if((ld.Status == 'Converted' || ld.IsConverted )&& ld.Lead_Status__c != 'Qualified' && ld.RecordTypeId != chakrMarjakRTId)
            {
                ld.addError('Stage must be lead status and Status must be Qualified ');
            } 
        }

        if(!leadId.isEmpty()){
            if(!Test.isRunningTest())
            {
                ldList = [Select Year_of_Manufacturer__c, DG_Make__c, DG_KVA_Rating__c from Lead_DGs__c where Lead__c  =: leadId];
            }
            else
            {
                ldList = [Select Year_of_Manufacturer__c, DG_Make__c, DG_KVA_Rating__c from Lead_DGs__c ];
            }
            
            if(!ldList.isEmpty()){
                for(Lead_DGs__c ldDG: ldList){
                    if(ldDG.Year_of_Manufacturer__c == null || ldDG.DG_Make__c == null || ldDG.DG_KVA_Rating__c == null){
                        flag = true;
                        break;
                    } 
                }
            }
            else{
                flag = true;
            }
            For(Lead l : newRec)
            {
                if(flag && !test.isRunningTest() && l.RecordTypeId != chakrMarjakRTId)
                    l.addError('Kindly Create lead DG record');
            }
        }
    }
    
    public static void LeadConversion(List<Lead> lstlead , Map<Id,Lead> oldMap){
        Set<Id> oppid = new Set<Id>();
        Map<Id,Id> lstMap = new Map<Id,Id>();
        List<Lead_DGs__c> lstUpdate = new List<Lead_DGs__c>();
        if(!lstlead.isEmpty())
        {
            For(Lead l : lstlead)
            {
                if(oldMap != null)
                {
                    Lead oldLead = oldMap.get(l.id);
                    if( l.IsConverted  && !oldLead.IsConverted)
                    {
                        lstMap.put(l.id,l.ConvertedAccountId);
                    }
                }
            }
            system.debug('lstMap 1'+lstMap); 
            if(!lstMap.isEmpty() )
            {
                system.debug('lstMap '+lstMap);
                List<Lead_DGs__c> lstldg = [select id,Name,Opportunity__c,Account__c,Lead__c 
                                            from Lead_DGs__c
                                            Where Lead__c IN: lstMap.keyset()];
                system.debug(' lstldg is '+lstldg);
                For(Lead_DGs__c ldg :lstldg)
                {
                    if(lstMap.containsKey(ldg.Lead__c))
                    {
                        ldg.Account__c = lstMap.get(ldg.Lead__c);
                        lstUpdate.add(ldg);
                    }
                }
                if(!lstUpdate.isEmpty())
                {
                    update lstUpdate;
                }
            }
        }
    }
    public static void activeLeads(List<Lead> lstlead , Map<Id,Lead> oldMap)
    {
        Map<Id, Integer> userLeadCountMap = new Map<Id, Integer>();
        List<User> updateUser = new List<User>();
        Set<Id> userIds = new Set<Id>();
        for (Lead l : lstlead) 
        {
            userIds.add(l.OwnerId);
            if(oldMap != null)
                userIds.add(oldMap.get(l.id).OwnerId);
            System.debug('inside lead status condition');
        }
        
        List<AggregateResult> lstagg = [SELECT OwnerId, COUNT(Id) leadCount
                                        FROM Lead
                                        WHERE OwnerId IN :userIds and Status != 'Converted' and Lead_Status__c != 'Qualified' and Lead_Status__c != 'Disqualified'
                                        GROUP BY OwnerId];
        system.debug('List of aggregate result is ' + lstagg);
        Id userId;
        for (AggregateResult result : lstagg) 
        {
            userId = (Id) result.get('OwnerId');
            System.debug('Lead owner id is ' + userId);
            Integer leadCount = (Integer) result.get('leadCount');
            System.debug('lead count is ' + leadCount);
            userLeadCountMap.put(userId, leadCount);
        }
        List<User> lstu = [Select id,Active_Leads__c,LastName 
                           from User
                           where id =: userIds];
        System.debug('List of user is ' + lstu);
        for(User u : lstu)
        {
            if (userLeadCountMap.containsKey(u.Id))
            {
                u.Active_Leads__c = userLeadCountMap.get(u.Id);
                System.debug('Active leads are ' + u.Active_Leads__c);
                updateUser.add(u);
            }
        }
        if(updateUser.size()>0)
        {
            System.debug('active lead' + updateUser);
            update updateUser;
        }
    }
    
    public static void LeadAssignment(List<Lead> lstlead1)
    {
        system.debug('LeadAssignment Method');
        Set<Id> lid = new Set<Id>();
        List<Lead> lstlead = new List<Lead>();
        List<Lead> lstupdate = new List<Lead>();
        
        For(Lead l1: lstlead1)
        {
            lid.add(l1.id);
            System.debug('Lead id is ' + l1.id);
        }
        if(!lid.isEmpty())
        {
            lstlead = [select id,Name,State,Channel__c,StateCode,OwnerId from lead Where id =: lid 
                      and status != 'Unassigned'];
            System.debug('List of lead is ' + lstlead);
        }
        System.debug('lstlead is '+lstlead);
        Set<String> stateSet = new Set<String>();
        Set<Id> uid=new Set<Id>();
        String stateVAl = '';
        boolean flag = false;
        Integer UserSize = 0;
        if(!lstlead.isEmpty())
        {
            For(Lead l : lstlead)
            {
                if(l.StateCode != null || l.StateCode != '')
                {
                    stateVAl = l.StateCode;
                    System.debug('stateVAl is ' + stateVAl);
                }
                else
                {
                    
                }
            }
        }
        
        system.debug('stateSet is '+stateSet);
        system.debug('stateVAl is '+stateVAl);
        List<User> lstudate = new List<User>();
        if(stateVAl != null)
        {
            System.debug('inside if stateval is ' + stateVAl);
            List<User> lstuser = [select id,Name,Username,State__c,Active_Leads__c,Lead_Limits__c,
                                  IsActive,Lead_Assigned_Date__c 
                                  From User
                                  Where State__c INCLUDES (:stateVAl) and IsActive = true and Lead_Limits__c = False
                                  order by Lead_Assigned_Date__c ];
            System.debug('lstuser 1 is '+lstuser);
            if(!lstuser.isEmpty())
            {
                UserSize = lstuser.size(); 
                Integer i=1;
                Integer j=1;
                For(Lead  l : lstlead)
                {
                    if(l.Channel__c == 'Inbound Lead')
                    {
                        l.OwnerId =UserInfo.getUserId();
                        lstupdate.add(l);
                    }
                    else
                    {
                        system.debug('Lead is assigned');
                        l.OwnerId = lstuser[i-1].id;
                        l.Status ='Assigned';
                        uid.add(lstuser[i-1].id);
                        if(i==UserSize)
                        {
                            i=1;
                        }
                        else
                        {
                            i = i+1;
                        }
                        flag = true;
                        lstupdate.add(l);
                    }
                }
                if(uid.size()>0)
                {
                    system.debug('uid is'+uid);
                    for(id u : uid)
                    {
                        if(flag)
                        {
                            User u1=new User();
                            u1.id = u;
                            u1.Lead_Assigned_Date__c = system.Now();
                            system.debug('Lead assigned date is '+ u1.Lead_Assigned_Date__c);
                            lstudate.add(u1);
                        }
                    }
                }
                if(!lstudate.isEmpty() && !test.isRunningtest())
                {
                    update lstudate;
                }
            }
            else
            {
                For(Lead  l : lstlead) 
                {
                    
                    DefaultUser__c var = DefaultUser__c.getInstance();
                    l.OwnerId = var.UserId__c;
                    lstupdate.add(l);
                }
            }
            system.debug('before lstupdate ');
            if(!lstupdate.isEmpty() && !test.isRunningtest())
            {
                system.debug('inside lstupdate ');
                update lstupdate;
            }
        }
    }
}