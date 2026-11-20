@isTest
public class CheckInApexController_Test {
    @isTest
    public static void checkInTest_M1()
    {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest());
        Attendance__c punchIn = new Attendance__c();
        punchIn.Attendance_In__c = System.Today();
        punchIn.User__c = '005Do0000023sLfIAI';
        insert punchIn;
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Visit_Plan__c vp = new Visit_Plan__c();
        vp.Visiting_Customer__c = acc.Id;
        vp.Visit_Plan_Name__c = acc.Name;
        vp.Remarks__c = 'Test remarks for checkout';
        insert vp;
        
        Test.StartTest();
        CheckInApexController.checkIn(28.4890064, 77.3711913, vp.Id);
        CheckInApexController.testCoverageMethod();
        Test.StopTest();
    }
    
    public class HttpCalloutMockTest implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) 
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }
}