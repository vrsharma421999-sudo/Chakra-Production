@isTest

Public class ActivityStage
{
     static testmethod void test()
     {
         
         Account Acc= new Account();
         acc.Name = 'acctest';
          acc.BillingCity='xyz';
        acc.BillingCountry='India';
         insert Acc;
         
         Opportunity Opp= new Opportunity();
         Opp.Name= 'test';
         Opp.AccountId = Acc.Id;
         
         insert Opp;
         //Test.starttest();
         Task task=new task();
         Task.Subject='call';
         Task.Priority='High';
         Task.Status='Open';
         Task.ActivityDate= System.today();
         Task.WhatId = Opp.Id;
         Task.Stage__c= Opp.StageName;
         insert task;
         
        // Test.stopTest();
         
     }
}