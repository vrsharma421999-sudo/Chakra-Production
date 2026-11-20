public class OpportunityStaleCloseScheduler implements Schedulable {
   
    public void execute(SchedulableContext sc) {
        OpportunityStaleCloseBatch batch = new OpportunityStaleCloseBatch();
        Database.executeBatch(batch, 200);
    }
}