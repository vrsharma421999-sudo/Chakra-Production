trigger MilestoneTrigger on Milestone__c (Before update) {
    if(Trigger.isBefore && Trigger.isUpdate){
       //MilestoneTriggerHandler.handle
        MilestoneHandler.calculateAmounts(Trigger.new, Trigger.oldMap);

    }
}