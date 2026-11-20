global class DealBatchSchedule implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        DealBatch batch = new DealBatch();
        database.executebatch(batch,1);
    }
}