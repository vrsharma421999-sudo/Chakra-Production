trigger ContractLineItemTrigger on Contract_Line_Item__c (after insert, after update) {
    System.debug('ContractLineItemTrigger fired. Event: ' + (Trigger.isInsert ? 'Insert' : 'Update'));
    Set<Id> lineItemIds = new Set<Id>();

    for (Contract_Line_Item__c item : Trigger.new) {
        System.debug('Processing Item: ' + item.Id + ', Serial: ' + item.RECD_Serial_No__c);

        if (Trigger.isInsert) {
            // On Insert 
            if (item.RECD_Serial_No__c != null) {
                lineItemIds.add(item.Id);
            } else {
                System.debug('Skipping Sync: Serial Number is null on Insert');
            }
        } else {
            // On Update
            Contract_Line_Item__c oldItem = Trigger.oldMap.get(item.Id);
            if (item.RECD_Serial_No__c != null && (
                item.Contract_Start_Date__c != oldItem.Contract_Start_Date__c ||
                item.Contract_End_Date__c != oldItem.Contract_End_Date__c         
            )) {
                lineItemIds.add(item.Id);
            } else if (item.RECD_Serial_No__c == null) {
                System.debug('Skipping Sync: Serial Number is null on Update');
            } else {
                System.debug('Skipping Sync: No relevant fields changed on Update');
            }
        }
    }

    System.debug('Final Sync IDs count: ' + lineItemIds.size());
    if (!lineItemIds.isEmpty()) {
        ContractUnoPoint.SyncContractLineItems(lineItemIds);
    }
}