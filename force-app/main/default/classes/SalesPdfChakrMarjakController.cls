public class SalesPdfChakrMarjakController {
    public Quote quoteRec {get;set;}
    public QuoteLineItem qliRec {get;set;}
    public User quoteOwner {get;set;}
    
    // Added by Vanshika on 2026-10-01: Compute GST and Total Device Cost based on discounted TotalPrice
    public Decimal gstAmount {
        get {
            if (qliRec != null && qliRec.TotalPrice != null) {
                return (qliRec.TotalPrice * 0.18).setScale(2, System.RoundingMode.HALF_UP);
            }
            return 0.00;
        }
        set;
    }

    public Decimal totalDeviceCost {
        get {
            if (qliRec != null && qliRec.TotalPrice != null) {
                return (qliRec.TotalPrice * 1.18).setScale(2, System.RoundingMode.HALF_UP);
            }
            return 0.00;
        }
        set;
    }
    
    public SalesPdfChakrMarjakController(ApexPages.StandardController stdController) {
        
        Id quoteId = ApexPages.currentPage().getParameters().get('id');
        
        quoteRec = [SELECT Id,Name,QuoteNumber,ExpirationDate,Account.Name,Comprehensive_Maintenance__c,Digital_Monitoring_App__c,Dedicated_Relationship_Mgr__c,
                    Category__c,Opportunityid,Payment__c,Submitted_To__c,Opportunity.Payment_Terms__c,Terms_And_Conditions__c,OwnerId,createdDate
                     FROM Quote WHERE Id = :quoteId LIMIT 1];
        String pdfFileName = 'CHK_P_' 
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
                                       TotalPrice,
                                       Refundable_Security_Deposit__c,
                                       Buyout_Option_post_lock_in__c,
                                       Reactivation_Charge_post_lock__c,
                                       Freight__c,Total_Initial_Commercials_Cost_In_GST__c,Strategic_Initial_Outflow__c,
                                       Strategic_Lock_in_Period__c,Strategic_Monthly_Rental_ex_GST__c,GST_Amount_1__c,UnitPrice,
                                       Upfront_Saving_vs_Purchase__c,Quantity,TotalBudgetary_Price__c
                                       FROM QuoteLineItem
                                       WHERE QuoteId = :quoteId
                                       LIMIT 1
                                      ];
        
        if(!qliList.isEmpty()){
            qliRec = qliList[0];
            
        }else{
            qliRec = new QuoteLineItem();
        }
    }
}