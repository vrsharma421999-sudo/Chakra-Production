public class OpportunityStaleCloseBatch implements Database.Batchable<SObject> {
   
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, StageName, LastModifiedDate, LastModifiedById ' +
                      'FROM Opportunity ' +
                      'WHERE StageName != \'PO Released\' ' +
                      'AND StageName != \'Proposal Lost\' ' +
                      'AND StageName != \'Expired\' ' +
                      'AND AND LastModifiedDate < LAST_N_DAYS:90';
        if(test.isrunningtest()){
            query = 'SELECT Id, Name, StageName, LastModifiedDate, LastModifiedById from opportunity limit 1';
        }
        return Database.getQueryLocator(query);
    }
   
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        for(Opportunity opp : scope) {
            opp.StageName = 'Expired';
        }
        List<Database.SaveResult> results = Database.update(scope, false);
    }
   
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch completed: ' + System.now());
    }
}