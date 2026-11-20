public class QuoteLineTrigger_Handler {
    public static void qli_M1(List<QuoteLineItem> qliList){
        List<QuoteLineItem> qliToUpdate = new List<QuoteLineItem>();
        for(QuoteLineItem q : qliList)
        {
            system.debug('Quote List >>> '+ qliList);
            system.debug('TotalPrice >>> '+ q.TotalPrice);
            system.debug('GST_Rate__c >>> '+ q.GST_Rate__c);
            if(q.TotalPrice != null && q.GST_Rate__c != null)
            {
                q.GST_Amount__c =  (q.TotalPrice * q.GST_Rate__c)/100;
                qliToUpdate.add(q);
            }
            system.debug('GST_Amount__c >>> '+ q.GST_Amount__c);
        }
    }
}