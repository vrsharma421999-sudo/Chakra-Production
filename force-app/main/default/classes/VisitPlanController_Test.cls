@isTest
public class VisitPlanController_Test {
    public static testmethod void m1(){
        
        User u = new User();
        u.Id = '005Uz000006Lv7t';
        
        Account acc = new Account();
        acc.Name = 'test acc';
        insert acc;
        
        List<Visit_Plan__c> lstvp = new List<Visit_Plan__c>();
        Visit_Plan__c vp = new Visit_Plan__c();
        vp.Visit_Planed_Date__c = System.today();
        vp.VisitAgenda__c = 'Order';
        vp.Contact_Person__c = 'Nikki';
        vp.Visiting_Customer__c = acc.Id;
        vp.OwnerId = u.Id;
        lstvp.add(vp);
        if(!lstvp.isEmpty()){
            insert vp;
        }
        
        test.startTest();
        VisitPlanController.searchUsers('nikki');
        VisitPlanController.createVisit(lstvp);
        VisitPlanController.visitMatch(vp.Visit_Planed_Date__c, u.Id);
        test.stopTest();
    }
}