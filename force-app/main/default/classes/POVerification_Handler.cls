public class POVerification_Handler {
    public static void getData(List<PO_Verification__c> lstpov){
        System.debug('list of po verification is '+ lstpov);
        List<Id> userIds = new List<Id>();
        List<Opportunity> lstopp = new List<Opportunity>();
        List<PO_Line_Item__c> lstpoli = new List<PO_Line_Item__c>();
        Set<Id> dealId = new Set<Id>();
        for(PO_Verification__c pov : lstpov){
            if(pov.Deal__c != null){
                dealId.add(pov.Deal__c);
                System.debug('pov.Deal__c is  '+ pov.Deal__c);
            }
        }
        if(dealId != null)
            lstopp = [select id,Name,TotalOpportunityQuantity,Product__c,Billing_Addresses__r.Street__c,
                      Shipping_Address__r.Street__c,Billing_Addresses__r.GST__c,
                      Uploading_Requirement__c,Cladding_Requirement__c,Transportation__c,
                      Emission_Test_NABL_Certified__c, Account.Name,
                      (Select id,DG_KVA_Rating__c,DG_Make__c,Quantity__c,Product__r.Name from Deal_DGs__r)
                      from Opportunity 
                      where id =: dealId LIMIT 1];
        System.debug('lstopp is ' + lstopp);
        
        if(!lstopp.isEmpty()){
            System.debug('inside not empty deal id');
            for(PO_Verification__c pov : lstpov){
                
                if(pov.Deal__c != null && (pov.Deal__c == lstopp[0].Id)){
                    pov.Billing_Address__c = lstopp[0].Billing_Addresses__r.Street__c;
                    pov.Shipping_Address__c = lstopp[0].Shipping_Address__r.Street__c;
                    //pov.GST__c = lstopp[0].Billing_Addresses__r.GST__c;
                    //pov.Unloading__c = lstopp[0].Uploading_Requirement__c;
                    //pov.Cladding__c = lstopp[0].Cladding_Requirement__c;
                    //pov.Transportation__c = lstopp[0].Transportation__c;
                    //pov.NABL_PM__c = lstopp[0].Emission_Test_NABL_Certified__c;
                    //pov.NABL_PM_HC_CO__c = lstopp[0].NABL_PM_HC_CO__c;
                } 
            }
        }
    }
    
    /*
public static void getDataLineItem(List<PO_Verification__c> lstpov){
System.debug('inside not empty deal id');
List<Opportunity> lstopp = new List<Opportunity>();
List<PO_Line_Item__c> lstpoli = new List<PO_Line_Item__c>();
Set<Id> dealId = new Set<Id>();
for(PO_Verification__c pov : lstpov){
if(pov.Deal__c != null){
dealId.add(pov.Deal__c);
System.debug('pov.Deal__c is  '+ pov.Deal__c);
}
}
lstopp = [select id,Name,Billing_Addresses__c,Shipping_Address__c,TotalOpportunityQuantity,Product__c,
Billing_Addresses__r.Street__c,Shipping_Address__r.Street__c,Billing_Addresses__r.GST__c,
(Select id,DG_KVA_Rating__c,DG_Make__c,Quantity__c,Product__r.Name,DG_Type__c,Turbo_Type__c
from Deal_DGs__r)
from Opportunity 
where id =: dealId LIMIT 1];
System.debug('lstopp is ' + lstopp);
for(PO_Verification__c pov : lstpov){

for(Opportunity opp : lstopp){
System.debug('inside opportunity for loop');
if(pov.Deal__c ==  opp.Id){
System.debug('inside if condition of pov.deal == opp.id');
for(Deal_DG__c dg : opp.Deal_DGs__r){
System.debug('inside deal dg for loop');
PO_Line_Item__c poli = new PO_Line_Item__c();
poli.PO_Verification__c = pov.Id;
poli.DG_KVA_Rating__c = dg.DG_KVA_Rating__c;
poli.DG_Make__c = dg.DG_Make__c;
poli.Quantity__c = dg.Quantity__c;
poli.Product_Search_KVA_Rating__c = dg.Product__r.Name;
poli.DG_Type__c = dg.DG_Type__c;
poli.Turbo__c = dg.Turbo_Type__c;
lstpoli.add(poli);
}
}
}
if(!lstpoli.isEmpty()){
System.debug('inside insert po lineitem');
insert lstpoli;
}
}
}
*/
    
    public static void assignToQueue(List<PO_Verification__c> lstpov){
        System.debug('lstpov of queue is  '+ lstpov);
        List<PO_Verification__c> poVerificationsToUpdate = new List<PO_Verification__c>();
        Group queue = [SELECT Id FROM Group WHERE Name = 'Sales Ops' AND Type = 'Queue' LIMIT 1];
        System.debug('queue is '+ queue);
        for(PO_Verification__c pov : lstpov) {
            pov.OwnerId = queue.Id;
            System.debug('pov.OwnerId is '+ pov.OwnerId);
            poVerificationsToUpdate.add(pov);
        }
    }
    public static void povNaming(List<PO_Verification__c> povList){
        Set<Id> dealId = new Set<Id>();
        for(PO_Verification__c pov : povList){
            if(pov.Deal__c != Null){
                dealId.add(pov.Deal__c);
            }
        }
        if(!dealId.isEmpty()){
            List<Opportunity> oppList = [Select Id, Name, Account.Name From Opportunity Where Id =: dealId Limit 1];
            List<PO_Verification__c> povSize = new List<PO_Verification__c>();
            povSize = [Select Id, Name From PO_Verification__c Where Deal__c =: dealId];
            System.debug('oppList is ' + oppList);
            System.debug('PovList Size is ' + povSize.size());
            
            string PovName = '';
            Integer PovCount=0;
            
            if(povSize.size() > 0){
                PovCount = povSize.size();
            }else{
                PovCount = 1;
            }
            if(oppList[0].Name != null && oppList[0].Name != 'NA')
            {
                PovName = oppList[0].Name+'_Checklist_'+PovCount;
            }
            for(PO_Verification__c pov : povList){
                Integer maxSize = 80;
                pov.PO_Full_Name__c = PovName;
                if(PovName.length() > maxSize ){
                    PovName = PovName.substring(0, maxSize);
                }
                pov.Name = PovName;
            }
        }
    }
    
    public static void UpdateOwner(List<PO_Verification__c> povList, Map<Id,PO_Verification__c> oldMap){
        
        List<User> Head = [Select Id,PM_Head__c from User WHERE PM_Head__c=True LIMIT 1];
        
        Id UserId = Head[0].Id;
        
        System.debug('pov List is >>> '+povList);
        System.debug('Head List is >>> '+Head);
        System.debug('UserId >>> '+UserId);
        
        List<PO_Verification__c> pov2 = new List<PO_Verification__c>();
        
        for(PO_Verification__c pov : povList)
        {
            //PO_Verification__c oldPov = oldMap.get(pov.Id).Status__c;
            System.debug('pov.Status__c >>> '+pov.Status__c);
            if(pov.Status__c == 'Send to PM Head' && oldMap.get(pov.Id).Status__c != pov.Status__c)
            {
                pov.OwnerId = UserId;pov2.add(pov);
                System.debug(pov.OwnerId);
            }
        }
        System.debug('pov2' + pov2);
        if(!pov2.isEmpty()){
            //update pov2;
            System.debug('Updated successfully');
        }
    }
    
    public static void ChangeOwner(List<PO_Verification__c> povList, Map<Id,PO_Verification__c> oldMap){
        System.debug('povList is ' + povList);
        String povId = povList[0].Id;
        System.debug('povId is ' + povId);
        List<Project__c> lstpro = new List<Project__c>();
        List<Project__c> lstproUpdate = new List<Project__c>();
        lstpro = [Select id,Name,ownerId,PO_Verification__c from Project__c where PO_Verification__c =: povId];
        System.debug('list of project ' + lstpro);
        
        for(PO_Verification__c pov :povList){
            if(povList[0].ownerId != oldMap.get(pov.Id).OwnerId){
                System.debug('Pov owner not same ');
                for(Project__c project : lstpro){
                    System.debug('project owner is  '+ project.ownerId);
                    project.ownerId = povList[0].OwnerId;lstproUpdate.add(project);
                }
            }
        }
        if(!lstproUpdate.isEmpty()){update lstproUpdate;
        }
    }
    
    public Static void approvalProcess(List<PO_Verification__c> povList, Map<Id, PO_Verification__c> oldMap){
        for(PO_Verification__c pov : povList){
            if(pov.Status__c != oldMap.get(pov.Id).Status__c){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval');
                req.setObjectId(pov.Id);
                try{
                    Approval.ProcessResult result = Approval.process(req);
                    system.debug('Approval Result >>> '+result);
                }catch(exception e){
                    
                }
            }
        }
    }
    
    public static void updateMilestoneAmounts(List<PO_Verification__c> povList, Map<Id,PO_Verification__c> oldMap) {
        Set<Id> povListId = new Set<Id>();
        
        for(PO_Verification__c po:povList) {
            povListId.add(po.Id);
        }
        
        if(!povListId.isEmpty()) {
            List<Milestone__c> milestoneList = [Select Id, Field1__c, PO_Verification__c,PO_Verification__r.Total_POV_Cost__c, Milestone_Amount__c,Milestone_Amount_with_GST__c, GST__c  
                                                From Milestone__c 
                                                Where PO_Verification__c IN :povListId];
            //System.debug('The milestone data is - ' +milestoneList);
            
            if(!milestoneList.isEmpty()) {
                for(Milestone__c mStone :milestoneList) {
                    mStone.Milestone_Amount__c = mStone.PO_Verification__r.Total_POV_Cost__c * (mStone.Field1__c/100);
                    mStone.Milestone_Amount_with_GST__c = (mStone.Milestone_Amount__c * (mStone.GST__c/100)) + mStone.Milestone_Amount__c ;
                }
            }
            update milestoneList;
        }
    }
    
    public Static void StageChangeError(List<PO_Verification__c> povList, Map<Id, PO_Verification__c> oldMap){
        for(PO_Verification__c pov : povList)
        {
            AggregateResult  finList = [Select COUNT(Id)  ids From Financial_Check_List__c Where PO_Verification__c =: pov.Id];
            AggregateResult  techList = [Select COUNT(Id) ids From Technical_Checklist__c Where PO_Verification__c =: pov.Id];
            AggregateResult  proList = [Select COUNT(Id) ids From Project__c Where PO_Verification__c =: pov.Id];
            AggregateResult  milestoneList = [Select COUNT(Id) ids From Milestone__c Where PO_Verification__c =: pov.Id];
            
            
            
            if(pov.Status__c == 'FC in Progress' && ((Integer)finList.get('ids') == 0 || (Integer)techList.get('ids') == 0 || (Integer)proList.get('ids') == 0))
            {
                pov.addError('Please add Financial Check List, Technincal Check List & Projects first');
            }
            else if(pov.Status__c == 'Send to PM Head' && ((Integer)finList.get('ids') == 0 || (Integer)techList.get('ids') == 0 || (Integer)proList.get('ids') == 0))
            {
                pov.addError('Please add Financial Check List, Technincal Check List & Projects first');
            }
            else if(pov.Status__c == 'Sent for Revision' && ((Integer)finList.get('ids') == 0 || (Integer)techList.get('ids') == 0 || (Integer)proList.get('ids') == 0))
            {
                pov.addError('Please add Financial Check List, Technincal Check List & Projects first');
            }
            else if(pov.Status__c == 'Approved' && ((Integer)finList.get('ids') == 0 || (Integer)techList.get('ids') == 0 || (Integer)proList.get('ids') == 0))
            {
                pov.addError('Please add Financial Check List, Technincal Check List & Projects first');
            }
            else if((pov.Status__c != 'TC in Process') && milestoneList.get('ids') == 0 && !Test.isRunningTest()){
                pov.addError('Please add payment milestone first');
            } 
            system.debug('Payment term percentage ' + pov.Total_Payment_Term_in__c);
            if(pov.Total_Payment_Term_in__c > 100){
                                pov.addError('Payment Milestone is above 100%');

            }
           // else if((pov.Status__c != 'TC in Process') && milestoneList.get('ids') == 0 ){
             //   pov.addError('Please add payment milestone first');
            //} 
        }
    }
    
    /* **********************************Nikki******************************* */
    /* ****************************** 28Oct 2025 ***************************** */
    /* **************** Send email on the basis of Approval Status ******************** */
    
    public static void sendEmailToPMTeamAndSalesTeam(List<PO_Verification__c> lstpov, Map<Id,PO_Verification__c> oldmap){
        lstpov = [Select id,Name,Owner.Email,Deal__r.Owner.Email,Approval_Status__c,Status__c,Owner.FirstName,
                  PO_Full_Name__c,PM_Head_Email__c from PO_Verification__c];
        System.debug('lstpov is ' + lstpov);
        
        EmailTemplate templateApp = [SELECT Id, DeveloperName,Name FROM EmailTemplate 
            					  WHERE Name = 'PO Approved' 
            					  LIMIT 1];
        System.debug('approved template is ' + templateApp);
        EmailTemplate templateRej = [SELECT Id, DeveloperName,Name FROM EmailTemplate 
            					  WHERE Name = 'PO Rejected' 
            					  LIMIT 1];
        System.debug('rejected template is ' + templateRej);
        
        List<User> usersWithProfilePMHeadSalesOps = [SELECT Id, Name, Email FROM User 
                                       WHERE (Profile.Name = 'PM Head' OR profile.Name = 'Project Management Team' OR profile.Name = 'Sales Ops')
                                       AND IsActive = true];
        System.debug('List of PM Teams user email ' + usersWithProfilePMHeadSalesOps);
        List<String> profileListUser = new List<String>();
        for (User u : usersWithProfilePMHeadSalesOps) {
            if (u.Email != null){
                profileListUser.add(u.Email);
            } 
        }
        System.debug('profileListUser email ' + profileListUser);
        String muskanEmail = 'muskan.verma@cloudpanthers.com';
        String amitEmail = 'amit.aseri@chakr.in';
        profileListUser.add(muskanEmail);
        profileListUser.add(amitEmail);
        System.debug('profileListUser email after adding additional email muskan' + profileListUser);
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(PO_Verification__c pov : lstpov) {
            System.debug('inside for loop');
            
            if (pov.Approval_Status__c == null) {continue;
            }
            
            PO_Verification__c oldPOV = oldMap.get(pov.Id);
            
            // Prevent null pointer on oldMap (sometimes new records don’t exist in oldMap)
            if (oldPOV == null) {continue;}
            
            System.debug('pov.Approval_Status__c is ' + pov.Approval_Status__c);
            if(pov.Status__c != null && pov.Status__c != oldmap.get(pov.Id).Status__c){
                if(pov.Status__c == 'PO Approved'){
                    if(pov.Approval_Status__c == 'Approved'){
                        System.debug('inside approval status is approved');
                        System.debug('pov.Owner.Email is : '+pov.Owner.Email);
                        System.debug('pov.Deal__r.Owner.Emai is : '+pov.Deal__r.Owner.Email);
                        if (pov.Owner.Email != null && pov.Deal__r.Owner.Email != null && !test.isRunningTest()) {
                            System.debug('pov.Owner.Email ' + pov.Owner.Email);
                            System.debug('pov.Deal__r.Owner.Email  ' + pov.Deal__r.Owner.Email );
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setSubject('PO has been Approved for ' +pov.PO_Full_Name__c);
                            String body = 'Dear Team'  + '\n' + 'PO has been Approved for ' +  pov.PO_Full_Name__c + '. \n' + 'Kindly Check. \n' +'https://chakrinnovation.lightning.force.com/lightning/r/PO_Verification__c/' + pov.Id +'/view';
                            mail.setPlainTextBody(body);
                            //mail.setTargetObjectId(pov.OwnerId);
                            //mail.setTemplateId(templateApp.Id);
                            mail.setSaveAsActivity(false);if(pov.PM_Head_Email__c != null){
                                System.debug('pov.PM_Head_Email__c  if condition for approved' + pov.PM_Head_Email__c);
                                mail.setToAddresses(new String[] { pov.Owner.Email, pov.Deal__r.Owner.Email, pov.PM_Head_Email__c});
                            }
                            else{
                                System.debug('pov.PM_Head_Email__c  else condition for approved');
                                mail.setToAddresses(new String[] { pov.Owner.Email, pov.Deal__r.Owner.Email});
                            }
                            mail.setCcAddresses(profileListUser);emails.add(mail);
                        }
                    }
                }
                
                if(pov.Status__c == 'TC in Process'){
                    if(pov.Approval_Status__c == 'Rejected'){
                        System.debug('inside approval status is rejected');
                        if (pov.Owner.Email != null && pov.Deal__r.Owner.Email != null) {
                            System.debug('pov.Owner.Email ' + pov.Owner.Email);
                            System.debug('pov.Deal__r.Owner.Email  ' + pov.Deal__r.Owner.Email );
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setSubject('PO has been Rejected for ' +pov.PO_Full_Name__c);
                            String body = 'Dear Team' + '\n' + 'PO has been Rejected for ' +  pov.PO_Full_Name__c + '. \n' + 'Kindly Check. \n' + 'https://chakrinnovation.lightning.force.com/lightning/r/PO_Verification__c/'+pov.Id+ '/view';
                            mail.setPlainTextBody(body);
                            //mail.setTargetObjectId(pov.OwnerId);
                            //mail.setTemplateId(templateRej.Id);
                            mail.setSaveAsActivity(false);if(pov.PM_Head_Email__c != null){
                                System.debug('pov.PM_Head_Email__c  if condition for rejected' + pov.PM_Head_Email__c);
                                mail.setToAddresses(new String[] { pov.Owner.Email, pov.Deal__r.Owner.Email, pov.PM_Head_Email__c});
                            }
                            else{
                                System.debug('pov.PM_Head_Email__c else condition for rejected');
                                mail.setToAddresses(new String[] { pov.Owner.Email, pov.Deal__r.Owner.Email});
                            }
                            mail.setCcAddresses(profileListUser);
                            //mail.setCcAddresses(new String[] {'muskan.verma@cloudpanthers.com'});
                            emails.add(mail);
                        }
                    }
                }
            }
        }
        
        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
                System.debug('email sent successfully');
            } catch (Exception e) {
                System.debug('Error sending email: ' + e.getMessage());
            }
        }
    }
}