global class LeadAPI_Schedule_Entity implements Schedulable
{
	global void execute(SchedulableContext sc) 
    {
        LeadAPI.AuthorizationMtd('entity1'); 
    }
}