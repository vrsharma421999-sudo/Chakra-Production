@isTest()
public class VisitPlanTrigger_Test {
    public static testmethod void m1(){
        test.startTest();
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'test con';
        con.MobilePhone = '8947529384';
        con.AccountId = acc.Id;
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.POC_Name__c = con.Id;
        opp.RecordTypeId = '012Do0000004ljvIAA';
        opp.CloseDate = Date.today().addDays(30);
        opp.Country__c = 'India';
        opp.Region__c  = 'North';
        opp.State__c  = 'Uttar Pradesh';
        opp.Product__c = 'RECD';
        opp.Order_Type__c = 'New Business';
        opp.City__c = 'Kanpur';
        opp.Sales_Consultant_Available__c = 'Involved';
        insert opp;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Opp';
        opp1.AccountId = acc.Id;
        opp1.POC_Name__c = con.Id;
        opp1.RecordTypeId = '012Do0000004ljvIAA';
        opp1.CloseDate = Date.today().addDays(30);
        opp1.Country__c = 'India';
        opp1.Region__c  = 'North';
        opp1.State__c  = 'Uttar Pradesh';
        opp1.Product__c = 'RECD';
        opp1.Order_Type__c = 'New Business';
        opp1.City__c = 'Kanpur';
        opp1.Sales_Consultant_Available__c = 'Involved';
        insert opp1;
        
        Visit_Plan__c vp = new Visit_Plan__c();
        vp.Visit_Type__c = 'HO/WFH/Plant visit';
        vp.Remarks__c = 'Test';
        insert vp;
        
        Visit_Plan__c vp3 = new Visit_Plan__c();
        vp3.Visiting_Customer__c = acc.Id;
        vp3.Visit_Type__c = 'New Customer';
        vp3.Visit_Planed_Date__c = System.today();
        vp3.Remarks__c = 'Test';
        insert vp3;
        
        Visit_Plan__c vp1 = new Visit_Plan__c();
        vp1.Visiting_Customer__c = acc.Id;
        
        vp1.Visit_Type__c = 'New Customer';
        vp1.Visit_Planed_Date__c = System.today();
        vp1.Remarks__c = 'Test';
        insert vp1;
        
        Visit_Plan__c vp2 = new Visit_Plan__c();
        vp2.Visiting_Customer__c = acc.Id;
        vp2.Deal__c = opp.Id;
        vp2.Visit_Type__c = 'Existing Customer';
        vp2.Remarks__c = 'Test';
        vp2.Visit_Planed_Date__c = System.today();
        insert vp2;
        
        delete vp2;
        
        Visit_Plan__c vp4 = new Visit_Plan__c();
        vp4.Visiting_Customer__c = acc.Id;
        vp4.Deal__c = opp.Id;
        vp4.Visit_Type__c = 'Existing Customer';
        vp4.Remarks__c = 'Test';
        vp4.Joint_Visit__c = true;
        vp4.Visit_Planed_Date__c = System.today();
        insert vp4;
        
        vp4.Remarks__c = 'Test Remarks';
        update vp4;
        test.stopTest();
    }
}