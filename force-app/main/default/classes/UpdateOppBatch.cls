global with sharing class UpdateOppBatch implements Database.Batchable<sObject>
{
	public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, (SELECT Id, Total_Amount__c FROM Quotes WHERE OpportunityId != null) FROM Opportunity LIMIT 10000]);
    }
 
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for (Opportunity opp : scope) {
            if (opp.Quotes != null && !opp.Quotes.isEmpty()) {
                Quote latestQuote = opp.Quotes[0];
                Opportunity updatedOpp = new Opportunity(Id = opp.Id);
                updatedOpp.Quote_Total_Price__c = latestQuote.Total_Amount__c;
                oppMap.put(opp.Id, updatedOpp);
            }
        }
        List<Opportunity> oppToUpdate = new List<Opportunity>(oppMap.values());
        if (!oppToUpdate.isEmpty()) {
            update oppToUpdate;
            System.debug('Updated Opportunities: ' + oppToUpdate);
        }
    }
 
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch process finished.');
    }
}