public class MilestoneHandler {
    
    public static void calculateAmounts(List<Milestone__c> newList, Map<Id, Milestone__c> oldMap) {
        Set<Id> poVerificationIds = new Set<Id>();
        
        for (Milestone__c ms : newList) {
            if (ms.PO_Verification__c != null) {
                poVerificationIds.add(ms.PO_Verification__c);
            }
        }
        
        if (poVerificationIds.isEmpty()) return;
        
        Map<Id, PO_Verification__c> poMap = new Map<Id, PO_Verification__c>(
            [SELECT Id, Total_POV_Cost__c FROM PO_Verification__c WHERE Id IN :poVerificationIds]
        );
        
        for (Milestone__c ms : newList) {
            Milestone__c oldMs = oldMap.get(ms.Id);
            
            Boolean gstChanged  = (ms.GST__c != oldMs.GST__c);
            Boolean termChanged = (ms.Field1__c != oldMs.Field1__c); 
            
            if ((gstChanged || termChanged) && poMap.containsKey(ms.PO_Verification__c)) {
                PO_Verification__c parentPO = poMap.get(ms.PO_Verification__c);
                
                Decimal totalCost = parentPO.Total_POV_Cost__c == null ? 0 : parentPO.Total_POV_Cost__c;
                                
                Decimal termPercent = ms.Field1__c == null ? 0 : ms.Field1__c / 100;
                Decimal gstPercent  = ms.GST__c == null ? 0 : ms.GST__c / 100;
                
                ms.Milestone_Amount__c = totalCost * termPercent;
                ms.Milestone_Amount_with_GST__c = ms.Milestone_Amount__c * (1 + gstPercent);
                
                System.debug(' total=' + totalCost + ' termFraction=' + termPercent + ' gstFraction=' + gstPercent
                             + ' ex=' + ms.Milestone_Amount__c + ' inc=' + ms.Milestone_Amount_with_GST__c);
            }
        }
    }
}