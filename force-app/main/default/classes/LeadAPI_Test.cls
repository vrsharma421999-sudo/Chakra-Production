@isTest
global class LeadAPI_Test 
{
    static testmethod void test() 
    {
        Test.startTest();
        LeadAPI.AuthorizationMtd('entity1');    
		
		LeadAPI_Json2Apex obj = new LeadAPI_Json2Apex();
        obj.RESPONSE  =new List<LeadAPI_Json2Apex.RESPONSE>();
		Test.stopTest();
    }
}