trigger LeadTrigger on Lead (After update,before update,before insert, After insert	) {
    if(trigger.isAfter && trigger.isUpdate){
        LeadTriggerHandler.LeadConversion(trigger.new, trigger.oldMap);
    }
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        LeadTriggerHandler.checkLeadDgFields(trigger.new , trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate){
        LeadTriggerHandler.activeLeads(trigger.new , trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        LeadTriggerHandler.LeadAssignment(Trigger.New);
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        LeadTriggerHandler.activeLeads(trigger.new , null);
    }
}