Trigger VisitPlanTrigger on Visit_Plan__c (before insert,after insert, after update, after delete, after undelete) {
    
    VisitPlanHandler.updateOpportunityVisitCount(
        Trigger.new,
        Trigger.old,
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.isDelete,
        Trigger.isUndelete
    );
    
    if(Trigger.isBefore && Trigger.isInsert){
        String accId =  '';
        for(Visit_Plan__c vp : Trigger.new){
            try {
                System.debug('vp.Visiting_Customer__c > '+vp.Visiting_Customer__c);
                if(vp.Visiting_Customer__c != null)
                {
                    VisitPlanHandler.setName(Trigger.new, vp.Visit_Type__c);
                }
                else if(vp.Visit_Type__c == 'HO/WFH/Plant visit')
                {
                    Date d = System.today();
                    String newDate = d.format();
                    System.debug('WFH newDate is ' + newDate);
                    vp.Visit_Plan_Name__c = vp.Visit_Type__c + '_' + String.valueOf(newDate);
                    System.debug('Name is else ' + vp.Visit_Plan_Name__c);
                }
            } catch (Exception e) {
                vp.addError('Error generating Visit Plan Name: ' + e.getMessage() + e.getLineNumber());
            }
        }
    }
}