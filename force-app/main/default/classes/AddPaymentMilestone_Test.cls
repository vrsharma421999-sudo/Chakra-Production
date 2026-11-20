@isTest
public class AddPaymentMilestone_Test {
    
    public static testmethod void method1(){
        test.startTest();
        Account Acc= new Account();
        Acc.Name='Test Account';
        insert Acc;
        
        Contact con=new Contact();
        con.LastName='test conn'; 
        con.AccountId=Acc.Id;
        insert con;
        
        Opportunity opp=new Opportunity();
        opp.AccountId=Acc.Id;
        opp.POC_Name__c=con.Id;
        opp.Country__c='India';
        opp.Region__c='North';
        opp.State__c='Haryana';
        opp.City__c='Mahendargarh';
        opp.Product__c='AMC';
        opp.Order_Type__c='New Business';
        opp.Sales_Consultant_Available__c='Not Involved';
        insert opp;
        
        PO_Verification__c poi = new PO_Verification__c();
        poi.GST__c='test gst';
        poi.PO__c='test po';
        poi.Deal__c=opp.Id;
        poi.Cladding__c='Chakr';
        poi.Unloading__c='Chakr';
        poi.Transportation__c='Chakr';
        poi.Piping_and_Structure__c='Chakr';
        poi.Comissioning_and_CR_Signoff__c='Chakr';
        poi.NABL_PM__c='Chakr';
        poi.NABL_PM_HC_CO__c='Chakr';
        poi.DOFF__c='Chakr';
        poi.GA_Drawing__c='Chakr';
        poi.Warranty__c='test warranty';
        poi.HSN_Code__c='HSN Code Mentioned Correctly';
        poi.Inco_Terms__c='DDP';
        poi.Payment_Terms__c='test pay';
        poi.RECD_Delivery_Timeline__c='test dt';
        poi.RECD_Installation_Timeline__c='test it';
        poi.LD_Clause__c='test clause';
        poi.LOI_Processing__c='NO';
        poi.Special_Remarks_RECD__c='test special';
        poi.Discount_Hike_LOI_Approver__c='Adeel Ahmed';
        insert poi;
        List<Milestone__c> mileList= new List<Milestone__c>();
        
        for(integer i = 0; i < 2 ; i++){
            Milestone__c m1 = new Milestone__c();
            m1.PO_Verification__c = poi.Id;
            m1.Field1__c = (90 * i);
            mileList.add(m1);
        }
        
        AddPaymentMilestone_Class.createRecord(mileList);
        AddPaymentMilestone_Class.getTotalAmount(poi.Id);
        test.stopTest();
    }
}