trigger AccountTrigger on Account (after update) {
    if(trigger.isBefore){
        //will handle before context
    }
    if(trigger.isAfter){
        AccountTriggerHandler.handleAcc(Trigger.new, Trigger.oldMap);
    }
}