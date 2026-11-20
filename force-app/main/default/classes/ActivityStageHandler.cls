public class ActivityStageHandler
{
		public static void DealStage(List<Task> ListTask)
        {
           Set<Id> OppId = new Set<Id>();
            
            for(Task tsk:ListTask)
            {
                if(tsk.WhatId!=null && string.valueof(tsk.WhatId).startswith('006'))
                  
                {
					OppId.add(tsk.WhatId);
                }
            }
            
            Map<Id,Opportunity> OppMap = new Map<Id,Opportunity>([Select Id,StageName from Opportunity WHERE Id IN:OppId]);
                       	
            for(Task task:ListTask)
            {
                if(task.WhatId!=null && OppMap.containsKey(task.WhatId))
                {
                    task.Stage__c=OppMap.get(task.WhatId).StageName;
                }
                
            }
            
            
           
        }
}