public class AddPaymentMilestone_Class {
    @AuraEnabled
    public static Decimal getTotalAmount(Id recordId) {
        PO_Verification__c po = [
            SELECT Total_POV_Cost__c 
            FROM PO_Verification__c 
            WHERE Id = :recordId
            LIMIT 1
        ];
        return po.Total_POV_Cost__c;
    }
    
    @AuraEnabled
    public static String createRecord(List<Milestone__c> mileList){
        try {
            insert mileList;
            return 'SUCCESS';
        } catch(DmlException e) {
            // Get the first error message (validation rules, field errors, etc.)
            //String errorMessage = e.getDmlMessage(0);
            throw new AuraHandledException(e.getDmlMessage(0));
        }/* catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
    }
}