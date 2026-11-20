@isTest
public class CheckOutApexController_Test {
    @isTest
    public static void setupTestData() 
    {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest());
        Visit_Plan__c visitPlan = new Visit_Plan__c(
            Check_In_Location__Latitude__s = 28.6076415,
            Check_In_Location__Longitude__s = 77.3711913,
            Remarks__c = 'Test remarks for checkout',
            OwnerId = UserInfo.getUserId()
        );
        insert visitPlan;
        
        Test.startTest();
        CheckOutApexController.checkout(28.500497, 77.318504, visitPlan.Id, 'Meeting Completed');
        Test.stopTest();
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