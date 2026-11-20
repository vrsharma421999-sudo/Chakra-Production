public class leadConvertedSendEmailClass 
{
    public static void sendEmail(List<Lead> leadList, map<id, lead> oldmap){
        if(!leadList.isEmpty())
        {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            for(Lead ld : leadList)
            {
                if(ld.IsConverted == True && oldmap.get(ld.id).isconverted == false)
                { 
                    Lead leadInfo = [Select Id, Name From Lead Where Id = : ld.Id];
                    User ownerInfo = [Select Id, Email, ManagerEmail__c From User Where Id =: ld.OwnerId];
                    Account accInfo = [Select Id, Name From Account where Id =: ld.ConvertedAccountId];
                    Opportunity oppInfo = [Select Id, Name, ManagerEmail__c, OwnerId From Opportunity where Id =: ld.ConvertedOpportunityId];
                    User ownerInfo1 = [Select Id, Email, ManagerEmail__c From User Where Id =: oppInfo.OwnerId];

                    
                    List<String> emailList = new List<String>();
                    //emaillist.add(ownerInfo.email);
                    
                    
                    if(ownerInfo1.ManagerEmail__c != null)
                    {
                        emaillist.add(ownerInfo1.ManagerEmail__c);
                        emaillist.add(ownerInfo1.Email);
                    } 
                    
                    string additionalemails = system.label.LeadConvertedEmails;
                    list<string> lstemails =  additionalemails.split(',');
                    for(string str: lstemails)
                    {
                        emaillist.add(str);
                    }
                    system.debug('Receiver Email');
                    
                    if (emaillist.size() > 0)
                    {
                         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                        email.setToAddresses(emailList);
                        email.setSubject(leadInfo.Name + ' lead is converted');
                        email.setPlainTextBody(leadInfo.Name + ' Lead is Converted to account : ' + accInfo.Name +' and to Opportunity : '+ oppInfo.Name);
                        emails.add(email);
                    }   
                   
                }
            }
            if(!emails.isEmpty())
            {
                if(LeadrecursionClass.setFlag == false){
                    Messaging.SendEmail(emails);
                    leadrecursionclass.setFlag = true;
                }
                
            }
        }
    }
}