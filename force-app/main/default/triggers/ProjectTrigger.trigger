trigger ProjectTrigger on Project__c (after insert, after update, before insert, before update) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        ProjectTriggerHandler.createProjectStageHistory(
            Trigger.new,
            null,
            true,
            false
        );
    }
    if(Trigger.isAfter && Trigger.isupdate){
        
        ProjectTriggerHandler.createProjectStageHistory(
            Trigger.new,
            Trigger.oldMap,
            false,
            true
        );
        
        for(Project__c pro : Trigger.new){
            if(pro.RECD_Sr_No__c != null && Trigger.oldMap.get(pro.Id).RECD_Sr_No__c == null){
                ProjectWebhook.sendJson(pro.Id);
            }
        }
    }
    if(Trigger.isBefore && Trigger.isInsert){
        ProjectTriggerHandler.changeStatus(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        ProjectTriggerHandler.changeStatusUpdate(Trigger.new, Trigger.oldmap);
        ProjectTriggerHandler.validateProjectDates(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        Set<Id> recordIds = new Set<Id>();
        
        for (Project__c rec : Trigger.new) {
            if (rec.CR_Signed__c == 'Yes' && Trigger.oldMap.get(rec.Id).CR_Signed__c != rec.CR_Signed__c) {
                recordIds.add(rec.Id);
            }
        }
        if (!recordIds.isEmpty()) {
            CustomerAssetAPIService.CreateAssetFromUNOPoint(recordIds);
        }
        ProjectTriggerHandler.handleCRSignOf(Trigger.new,Trigger.oldMap);
    }
}