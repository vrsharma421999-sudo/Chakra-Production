@isTest
public class LeadAPI_Schedule_Entity_Test
{
	public static testMethod void testschedule()
    {
        Test.StartTest();
        System.schedule('LeadAPI test','0 0 * * * ?',new LeadAPI_Schedule_Entity());
        Test.stopTest();
    }
}