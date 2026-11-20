public class RentalBudgetaryPdfController{
    
    public Quote quoteRec {get;set;}
    public User quoteOwner {get;set;}
    
    
    public QuoteLineItem qliRec {get;set;}
    public Decimal strvalue {get;set;}
    public Decimal intGstRate {get;set;}
    
    public RentalBudgetaryPdfController(ApexPages.StandardController stdController) {
        
        Id quoteId = ApexPages.currentPage().getParameters().get('id');
        
        quoteRec = [SELECT Id,Name,Submitted_To__c,ExpirationDate,Account.Name,Comprehensive_Maintenance__c,Digital_Monitoring_App__c,Dedicated_Relationship_Mgr__c,
                    Valid_for__c,Category__c,QuoteNumber,
                    Delivery__c,OwnerId,CreatedDate FROM Quote WHERE Id = :quoteId LIMIT 1];
        String pdfFileName = 'CHK_S_' 
    + quoteRec.CreatedDate.format('yyyy-MM-dd') 
    + '_' 
    + quoteRec.QuoteNumber
    + '.pdf';

ApexPages.currentPage().getHeaders().put(
    'Content-Disposition',
    'inline; filename="' + pdfFileName + '"'
);
        
        quoteOwner = [SELECT Id,Name,Email,MobilePhone,Title FROM User WHERE Id = :quoteRec.OwnerId LIMIT 1];
        
        List<QuoteLineItem> qliList = [SELECT Id,
                                       Monthly_Rental_ex_GST__c,GST_Rate__c,
                                       Monthly_Rental_incl_GST_18__c,
                                       Onboarding_Fee_ex_GST_one_time__c,
                                       Minimum_Lock_in_Period__c,
                                       Maintenance__c,
                                       Late_Payment_Charge__c,
                                       Consumables__c,
                                       Refundable_Security_Deposit__c,
                                       //Initial_Customer_Outflow__c,
                                       Buyout_Option_post_lock_in__c,
                                       Reactivation_Charge_post_lock__c,
                                       Freight__c,Total_Initial_Commercials_Cost_In_GST__c,Strategic_Initial_Outflow__c,Strategic_Lock_in_Period__c,Strategic_Monthly_Rental_ex_GST__c,
                                       Upfront_Saving_vs_Purchase__c,GST_Amount_1__c
                                       FROM QuoteLineItem
                                       WHERE QuoteId = :quoteId
                                       LIMIT 1
                                      ];
        
        if(!qliList.isEmpty()){
            qliRec = qliList[0];
            strvalue = (qliRec.Refundable_Security_Deposit__c == null ? 0 : qliRec.Refundable_Security_Deposit__c) +
                (qliRec.Onboarding_Fee_ex_GST_one_time__c == null ? 0 : qliRec.Onboarding_Fee_ex_GST_one_time__c);
            
        }else{
            qliRec = new QuoteLineItem();
            strvalue = 0;
        }
    }
    public String getCustomerPitchAmount() {
        
        Decimal amt = qliRec.Total_Initial_Commercials_Cost_In_GST__c;
        
        if(amt == null) {
            return '';
        }
        
        // Crore
    if(amt >= 10000000) {

        Decimal croreValue = amt / 10000000;

        String strVal = String.valueOf(croreValue);

        Integer dotPos = strVal.indexOf('.');

        if(dotPos > 0 && strVal.length() > dotPos + 2) {
            strVal = strVal.substring(0, dotPos + 3);
        }

        return strVal + ' crore';
    }
        
       else if(amt >= 100000) {
            
            Decimal lakhValue = amt / 100000;
            
            // Truncate instead of rounding
            String strVal = String.valueOf(lakhValue);
            
            Integer dotPos = strVal.indexOf('.');
            
            if(dotPos > 0 && strVal.length() > dotPos + 2){
                strVal = strVal.substring(0, dotPos + 3);
            }
            
            return strVal + ' lakh';
        }
        else if(amt >= 1000) {
            
            Integer thousandValue = Integer.valueOf(Math.floor(amt / 1000));
            
            return thousandValue + ' thousand';
        }
        
        return String.valueOf(amt);
    }
}