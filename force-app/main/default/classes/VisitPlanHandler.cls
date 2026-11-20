public class VisitPlanHandler {
    public static void setName(List<Visit_Plan__c> lstvp, String type){
        /*
        Date d = System.today();
        String newDate = d.format();
        System.debug('newDate is ' + newDate);
        */
        
        /* 	Changes done by Nikki Pandey
         * 28th Oct 2025
		visit plan name has been changed previously it was todays date but currently it is Visit_Planed_Date */
        Date d;
        
        Set<Id> accountIds = new Set<Id>();
        for(Visit_Plan__c vp : lstvp) {
            if(vp.Visiting_Customer__c != null) {
                accountIds.add(vp.Visiting_Customer__c);
            }
            if(vp.Visit_Planed_Date__c != null){
                d = vp.Visit_Planed_Date__c;
            }
        }
        String newDate = d.format();
        System.debug('newDate is ' + newDate);
        
        Map<Id, Account> accountMap = new Map<Id, Account>();
        if(!accountIds.isEmpty()) {
            accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :accountIds]);
        }
        
        Map<Id, List<Visit_Plan__c>> existingVisitPlansMap = new Map<Id, List<Visit_Plan__c>>();
        Map<Id, Integer> accountCountMap = new Map<Id, Integer>();
        
        if(!accountIds.isEmpty()) {
            List<Visit_Plan__c> existingPlans = [
                SELECT Id, Visiting_Customer__c, Visiting_Customer__r.Name, Visit_Planed_Date__c, CreatedDate
                FROM Visit_Plan__c 
                WHERE Visiting_Customer__c IN :accountIds
                ORDER BY Visiting_Customer__c, CreatedDate ASC
            ];
            
            for(Visit_Plan__c existingPlan : existingPlans) {
                Id accountId = existingPlan.Visiting_Customer__c;
                
                if(!existingVisitPlansMap.containsKey(accountId)) {
                    existingVisitPlansMap.put(accountId, new List<Visit_Plan__c>());
                    accountCountMap.put(accountId, 0);
                }
                existingVisitPlansMap.get(accountId).add(existingPlan);
                accountCountMap.put(accountId, accountCountMap.get(accountId) + 1);
            }
        }
        
        for(Visit_Plan__c vp : lstvp) {
            if(vp.Visiting_Customer__c == null) {
                continue;
            }
            
            Id accountId = vp.Visiting_Customer__c;
            Integer currentCount = accountCountMap.containsKey(accountId) ? accountCountMap.get(accountId) + 1 : 1;
            
            accountCountMap.put(accountId, currentCount);
            
            String customerName = '';
            if(accountMap.containsKey(accountId)) {
                customerName = accountMap.get(accountId).Name;
            }
            
            if(type != 'HO/WFH/Plant visit' && customerName != null) {
                
                if(vp.Joint_Visit__c == false) {
                    vp.Visit_Plan_Name__c = customerName + '_' + newDate + '_' + currentCount;
                    System.debug('Non-joint visit name: ' + vp.Visit_Plan_Name__c);
                    
                } else if(vp.Joint_Visit__c == true) {
                    String plannedDate = '';
                    String newDate1 = '';
                    if(vp.Visit_Planed_Date__c != null) {
                        plannedDate = String.valueOf(vp.Visit_Planed_Date__c);
                        System.debug('plannedDate is ' + plannedDate);
                        Date parsedDate = Date.valueOf(plannedDate);
                        newDate1 = parsedDate.day() + '/' + parsedDate.month() + '/' + parsedDate.year();
                        System.debug('Converted date: ' + newDate1);
                    }
                    vp.Visit_Plan_Name__c = customerName + '_' + newDate1 + '_' + currentCount;
                    System.debug('Joint visit name: ' + vp.Visit_Plan_Name__c);
                }
                
            } else if(customerName != null) {
                vp.Visit_Plan_Name__c = customerName + '_' + newDate + '_' + currentCount;
                System.debug('Fallback name: ' + vp.Visit_Plan_Name__c);
            }
        }
    }
    
    public static void setName(List<Visit_Plan__c> lstvp, Id accId, String type){
        setName(lstvp, type);
    }
    
    public static void updateOpportunityVisitCount(
        List<Visit_Plan__c> newList,
        List<Visit_Plan__c> oldList,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete,
        Boolean isUndelete
    ) {

        Set<Id> opportunityIds = new Set<Id>();

        // Insert & Undelete
        if (isInsert || isUndelete) {
            for (Visit_Plan__c vp : newList) {
                if (vp.Deal__c != null) {
                    opportunityIds.add(vp.Deal__c);
                }
            }
        }

        // Delete
        if (isDelete) {
            for (Visit_Plan__c vp : oldList) {
                if (vp.Deal__c != null) {
                    opportunityIds.add(vp.Deal__c);
                }
            }
        }

        // Update
        if (isUpdate) {
            for (Visit_Plan__c vp : newList) {

                // New Deal__c
                if (vp.Deal__c != null) {
                    opportunityIds.add(vp.Deal__c);
                }

                // Old Deal__c (if lookup changed)
                Visit_Plan__c oldVp = oldList.get(newList.indexOf(vp));

                if (oldVp.Deal__c != null) {
                    opportunityIds.add(oldVp.Deal__c);
                }
            }
        }

        if (opportunityIds.isEmpty()) {
            return;
        }

        // Count Visit Plans per Deal__c
        Map<Id, Integer> visitCountMap = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT Deal__c oppId, COUNT(Id) total
            FROM Visit_Plan__c
            WHERE Deal__c IN :opportunityIds
            GROUP BY Deal__c
        ]) {
            visitCountMap.put(
                (Id) ar.get('oppId'),
                (Integer) ar.get('total')
            );
        }

        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for (Id oppId : opportunityIds) {
            oppsToUpdate.add(new Opportunity(
                Id = oppId,
                No_of_Visits__c = visitCountMap.containsKey(oppId)
                    ? visitCountMap.get(oppId)
                    : 0
            ));
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}