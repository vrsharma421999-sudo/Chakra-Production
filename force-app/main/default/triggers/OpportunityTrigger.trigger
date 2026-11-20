trigger OpportunityTrigger on Opportunity (after update,before insert,after insert)
{
    // Check custom label to control trigger execution
    if(Label.OpportunityTrigger != 'True')
    {
        return;
    }

	If(Trigger.isAfter && Trigger.isUpdate)
    {
        OpportunityTriggerHandler.checkFileUploaded(Trigger.new, Trigger.oldMap);
        OpportunityTriggerHandler.CheckQuote(Trigger.New);
        OpportunityTriggerHandler.CloneAMCOppHandler(Trigger.new, Trigger.oldMap);
    }
    
    If(Trigger.isbefore && Trigger.isUpdate)
    {
          OpportunityTriggerHandler.ManagerEmail(Trigger.new);

    }
    If(Trigger.isbefore && Trigger.isinsert )
    {
        OpportunityTriggerHandler.DealNaming(Trigger.new);
        OpportunityTriggerHandler.DealCloseDate(Trigger.new);
    }    
}