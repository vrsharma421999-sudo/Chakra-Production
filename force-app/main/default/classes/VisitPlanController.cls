public class VisitPlanController {
    @AuraEnabled
    public static List<User> searchUsers(String searchKey) {
        String searchString = '%' + searchKey + '%';
        return [SELECT Id, Name, Email FROM User WHERE Name LIKE :searchString LIMIT 10];
    }
    
    @AuraEnabled
    public static List<Visit_Plan__c> visitMatch(Date visitDate, String userId){
        //System.debug('visit date is ' + visitDate);
        //System.debug('user is ' + userId);
        List<Visit_Plan__c> lstvp = new List<Visit_Plan__c>();
        lstvp = [SELECT Id, Name, Visit_Planed_Date__c,Contact_Person__c,VisitAgenda__c,
                 Visiting_Customer__r.Name,OwnerId 
                 FROM Visit_Plan__c 
                 WHERE Visit_Planed_Date__c =: visitDate 
                 and ownerId =: userId];
        //System.debug('lst of visit plan according to visit planed date is : ' + lstvp);
        //System.debug('lst of visit plan size is : ' + lstvp.size());
        return lstvp;
    }
    
    @AuraEnabled
    public static boolean createVisit(List<Visit_Plan__c> lstvp){
        //System.debug('visit plan list is '  + lstvp);
        
        Id currentUserId = UserInfo.getUserId();
        Integer count = 0;
        String accName = '';
        List<Visit_Plan__c> newVisit = new List<Visit_Plan__c>();
        for(Visit_Plan__c vp : lstvp)
        {
            if ((vp.Visit_Type__c == 'New Customer' || vp.Visit_Type__c == 'Existing Customer' || vp.Visit_Type__c == 'Adhoc') && String.isBlank(vp.Visiting_Customer__c))
            {
                throw new AuraHandledException('Missing Customer for Visit Type: ' + vp.Visit_Type__c);
            }
            else
            {
                Visit_Plan__c vt = new Visit_Plan__c();
                vt.Joint_Visit__c = true;
                vt.Visit_Planed_Date__c = vp.Visit_Planed_Date__c;
                vt.Visiting_Customer__c = vp.Visiting_Customer__c;
                vt.VisitAgenda__c = vp.VisitAgenda__c;
                vt.Contact_Person__c = vp.Contact_Person__c;
                vt.OwnerId = currentUserId;
                vt.Visit_Type__c = 'Joint Visit';
                vt.Visit_Plan__c = vp.Id;
                newVisit.add(vt);
                //insert vt;
            }
        }
        System.debug('newVisit is ' + newVisit);
        if(!newVisit.isEmpty()){
            system.debug('visit inserted successfully');
            insert newVisit;
            return true;
        }
        else{
            system.debug('visit not inserted successfully');
            return false;
        }
        //return true;
    }
}