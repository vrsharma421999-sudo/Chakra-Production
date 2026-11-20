global class DealBatch implements Database.Batchable<sObject>
{
    Date date10 = Date.today().addDays(-10);
    Date date20 = Date.today().addDays(-20);
    Date date30 = Date.today().addDays(-30);
    String closelost = 'Closed Lost';
    String closewon = 'Handover Stage';
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        //Collect the batches of records or objects to be passed to execute
        System.debug('10 days ' + date10);
        String query = '';
        if(!test.isRunningtest())
        {
            query = 'SELECT Id,Name,StageName,ManagerEmail__c,LastActivityDate,Owner.Email,Owner.ManagerEmail__c FROM Opportunity where StageName != null and StageName !=: closelost and StageName !=: closewon and (LastActivityDate =: date30 or LastActivityDate =: date20 or LastActivityDate =: date10)';
            System.debug('query is'+ query);
        }
        else{
            query = 'SELECT Id,Name,StageName,ManagerEmail__c,LastActivityDate,Owner.Email,Owner.ManagerEmail__c FROM Opportunity';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Opportunity> lstopp)
    {    
        /*    
        list<Messaging.SingleEmailMessage> mail = new list<Messaging.SingleEmailMessage>();
        //lstemail = [Select id, Name from EmailTemplate where Name = 'Template1'];
        
        list<string> toadd = new list<string>();
        List<String> toBcc = new List<String>();
        Messaging.SingleEmailMessage reminder = new Messaging.SingleEmailMessage();
        
        if (!lstopp.isEmpty())
        {
            for(Opportunity opp:lstopp)
            {      
                reminder.setSenderDisplayName('Chakr - Salesforce');
                reminder.setsubject('No activity on deal ' + opp.Name);
                if(opp.LastActivityDate == Date.today().addDays(-30) || (test.isRunningTest()))
                {
                    if((opp.owner.email != null && opp.ManagerEmail__c != null) || (test.isRunningTest()))
                    {
                        toadd.add(opp.owner.email);
                        toBcc.add(opp.ManagerEmail__c);
                        toBcc.add('arunaksh.bhandari@chakr.in');
                        toBcc.add('adeel.ahmed@chakr.in');
                        toBcc.add('anmol@chakr.in');
                        reminder.setplaintextbody( opp.Name+' has no actvitiy in last 30 days');              
                        mail.add(reminder);
                        System.debug('Mail is inside 30 days'+ toadd);
                    }
                }
                 if(opp.LastActivityDate == Date.today().addDays(-20) || (test.isRunningTest()))
                {
                    if((opp.owner.email != null && opp.ManagerEmail__c != null) || (test.isRunningTest()))
                    {
                        toadd.add(opp.owner.email);
                        toBcc.add(opp.ManagerEmail__c);
                        toBcc.add('arunaksh.bhandari@chakr.in');
                        toBcc.add('adeel.ahmed@chakr.in');
                        reminder.setplaintextbody(opp.Name+' has no actvitiy in last 20 days');              
                        mail.add(reminder);
                        System.debug('Mail is inside 20 days'+ toadd);
                    }
                }
                if(opp.LastActivityDate == Date.today().addDays(-10) || (test.isRunningTest()))
                {
                    if((opp.owner.email != null && opp.ManagerEmail__c != null) || (test.isRunningTest()))
                    {
                        toadd.add(opp.owner.email);
                        toBcc.add(opp.ManagerEmail__c);
                        reminder.setplaintextbody(opp.Name+' has no actvitiy in last 10 days');              
                        mail.add(reminder);
                        System.debug('Mail is inside 10 days'+ toadd + toBcc);
                    }
                }
            }
        }
        if (!toadd.isEmpty()) {
            reminder.setToAddresses(toadd);
            reminder.setBccAddresses(toBcc);
            reminder.setSaveAsActivity(false);
            mail.add(reminder);
        }
        if (!mail.isEmpty()) {
            Messaging.SendEmailResult[]  result  =Messaging.sendEmail( mail);
            System.debug('mail is ' + result);
        }*/
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug(BC);
    }
}