@isTest(SeeAllData=true)
public class CheckoutTest {
    
    
    
    public static testmethod void testmethod1(){
        
        
         Tour_Plan__c tour=new Tour_Plan__c();
       // tour.Name='test Tour';
        insert tour;
        Visit_Plan__c retailer = new Visit_Plan__c(Tour_Plan__c=tour.Id);
        insert retailer;
        PageReference pageRef = Page.CheckInServiceVisitCtrlVF;
        pageRef.getParameters().put('id',retailer.Id);
        pageRef.getParameters().put('Index','1');
        pageRef.getParameters().put('Index1','1');
        pageRef.getParameters().put('Index2','1');
        Test.setCurrentPage(pageRef);
        Apexpages.StandardController stdController = new Apexpages.StandardController(retailer);
        CheckInServiceVisitCtrl VisitcheckIn = new CheckInServiceVisitCtrl(stdController);
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mockservice1');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        VisitcheckIn.iFoundYou();
        
        VisitcheckIn.iFoundYou1();
  Test.stopTest();
       
      

        }
    
}