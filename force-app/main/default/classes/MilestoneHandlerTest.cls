@isTest
public class MilestoneHandlerTest {
    
    @isTest
    static void testMilestoneHandler() {
        
        PO_Verification__c po = new PO_Verification__c();
        insert po;
        
        Milestone__c ms = new Milestone__c(
            PO_Verification__c = po.Id,
            Field1__c = 10,
            GST__c = 18
        );
        insert ms;
        
        ms.Field1__c = 20;
        ms.GST__c = 20;
        
        Test.startTest();
        update ms;
        Test.stopTest();
        
        ms = [SELECT Milestone_Amount__c, Milestone_Amount_with_GST__c 
              FROM Milestone__c WHERE Id = :ms.Id];
        System.assertNotEquals(null, ms.Milestone_Amount__c);
        System.assertNotEquals(null, ms.Milestone_Amount_with_GST__c);
    }
}