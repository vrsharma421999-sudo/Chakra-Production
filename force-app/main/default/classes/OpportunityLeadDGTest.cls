@isTest
public class OpportunityLeadDGTest {
    static TestMethod void test()
    {    
        Account Acc= new Account();
        Acc.Name='Test Account';
        insert Acc;
        
        Lead led= new Lead();
        led.FirstName = 'ii';
        led.LastName ='dd';
        led.Status='Open';
        led.Company='test company';
        led.MobilePhone='9857575345';
        led.Channel__c='Marketing';
        led.DG__c='Yes';
        led.Source__c='Paid';
        
        insert led;
        
        Lead_DGs__c LDG= new Lead_DGs__c();
        //LDG.Total_Individual_KVA__c= 020;
       // LDG.Quantity__c=4;
        LDG.Account__c=Acc.Id;
        LDG.Year_of_Manufacturer__c='2001';
        insert LDG;
        
        Opportunity opp= new Opportunity();
        opp.AccountId=Acc.Id;
        opp.Name='test opp';
        opp.StageName='Proposal';
        opp.CloseDate=system.today();
        insert opp;
        
        
        List<Opportunity>lstopp= new List<Opportunity>();
        Opportunity OPPOBJ= new Opportunity();
        OPPOBJ.AccountId=Acc.id;
        OPPOBJ.Name='Test Opp';
        OPPOBJ.StageName='Proposal';
        OPPOBJ.CloseDate=system.today();
        insert OPPOBJ;
        String str ='[{"checkboxvalue": true,"leadRecord": {"Id": "a01DI000000Y66lYAC","Turbo_Type__c": "Twin Turbo","Year_of_Manufacturer__c": 2013,"DG_KVA_Rating__c": 7,"Lead__c": "00QDI0000017iP22AI"}}]';
        //String str ='[{"checkboxvalue":false,"leadRecord":{"Id":"a01DI000000Y66lYAC","Turbo_Type__c":"Twin Turbo","Year_of_Manufacturer__c":2013,"Quantity__c":3,"Total_Individual_KVA__c":4,"Dual_Fuel_Kit__c":"Yes","DG_KVA_Rating__c":7,"Lead__c":"00QDI0000017iP22AI"}},{"checkboxvalue":true,"leadRecord":{"Id":"a01DI000000Y66gYAC","Turbo_Type__c":"Twin Turbo","Year_of_Manufacturer__c":2018,"Quantity__c":2,"Total_Individual_KVA__c":2,"Dual_Fuel_Kit__c":"Yes","DG_KVA_Rating__c":6,"Lead__c":"00QDI0000017iP22AI"}},{"checkboxvalue":false,"leadRecord":{"Id":"a01DI000000Y66bYAC","Turbo_Type__c":"Single Turbo","Year_of_Manufacturer__c":2019,"Quantity__c":1,"Total_Individual_KVA__c":5,"Dual_Fuel_Kit__c":"Yes","DG_KVA_Rating__c":4,"Lead__c":"00QDI0000017iP22AI"}},{"checkboxvalue":false,"leadRecord":{"Id":"a01DI000000Y66qYAC","Turbo_Type__c":"Single Turbo","Year_of_Manufacturer__c":2015,"Quantity__c":1,"Total_Individual_KVA__c":3,"Dual_Fuel_Kit__c":"No","DG_KVA_Rating__c":5,"Lead__c":"00QDI0000017iP22AI"}}]';
      	Test.startTest();
        OpportunityLeadDGAP.ee(OPPOBJ.Id);
        OpportunityLeadDGAP.insertLeadDG(OPPOBJ.Id, str);
        Test.stopTest();
    }

}