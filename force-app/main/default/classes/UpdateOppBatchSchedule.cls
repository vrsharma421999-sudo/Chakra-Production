global class UpdateOppBatchSchedule implements Schedulable 
{
	global void execute(SchedulableContext sc) {
        UpdateOppBatch batch = new UpdateOppBatch();
         database.executebatch(batch,200);
    }
}