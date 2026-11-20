@isTest
public class CheckInServiceVisitCtrlTest {
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
        VisitcheckIn.iFoundYou();
        VisitcheckIn.iFoundYou1();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('geoLoc');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        }}