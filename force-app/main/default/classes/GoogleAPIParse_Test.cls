@isTest
private class GoogleAPIParse_Test{
  @testSetup
  static void setupTestData(){
    test.startTest();
    Visit_Plan__c leads_Obj = new Visit_Plan__c(Zone__c = 'North');
    Insert leads_Obj; 
    test.stopTest();
  }
  static testMethod void bj(){

      GoogleAPIParse value =new GoogleAPIParse();
      try{value= GoogleAPIParse.parse('test data');}catch(Exception e){}


  }
}