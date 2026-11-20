/* @AUTHOR       : Nikki Pandey
* @DESCRIPTION   : on button click create financial and technical checklist record
* @CREATEDATE    : 4-JAN-2025
* @MODIFIEDDATE :
*/

public class CreateFinancialCheckListHandler {
    @AuraEnabled
    public static void createFinancialCheckList(Id recordId){
        System.debug('record id is ' + recordId);
        List<PO_Verification__c> lstpov = [select id,Name,HSN_Code__c,DFK_Installation_Timeline__c,Channel_Partner_PoC_Number__c,
                                           Payment_Terms__c,Warranty__c,PO__c,Discount_Hike_LOI_Approver__c,Average_Discount_Provided__c,
                                           DFK_Delivery_Timeline__c,Total_Discount_Hike__c,GST__c,
                                           Company_Name__c,Billing_Address__c,Shipping_Address__c,End_Client_PoC_Name__c, 
                                           End_Client_PoC_Number__c,End_Client_PoC_Email__c,Channel_Partner_Company__c,Channel_Partner_Address__c,
                                           Channel_Partner_PoC_Name__c,Channel_Partner_PoC_Email__c,DG_Rating__c,
                                           Product__c,RECD_Delivery_Timeline__c,RECD_Installation_Timeline__c,Piping_and_Structure__c,
                                           GA_Drawing__c,Inco_Terms__c,Transportation__c,Unloading__c,Cladding__c,NABL_PM__c,NABL_PM_HC_CO__c,
                                           Comissioning_and_CR_Signoff__c,LD_Clause__c,Special_Remarks_RECD__c,DOFF__c,Supervision_Required__c,
                                           Channel_Partner_Involved__c,Total_Chakr_Shield_Quantity__c,Chakr_Shield_2_0_M2__c,
                                           Chakr_Shield_2_0_M3__c,Chakr_Shield_2_0_M4__c,Chakr_Shield_2_0_M1__c,Supervision_Charges_per_day_per_DG__c
                                           from PO_Verification__c 
                                           where Id =: recordId];
        
        List<Opportunity> lstopp = new List<Opportunity>();
        List<PO_Line_Item__c> lstpoli = new List<PO_Line_Item__c>();
        List<PO_Verification__c> Povsize = new List<PO_Verification__c>();
        List<Financial_Check_List__c> finaSize = new List<Financial_Check_List__c>();
        List<Technical_Checklist__c> TechSize = new List<Technical_Checklist__c>();
        List<Financial_Check_List__c> insertlstfcl = new List<Financial_Check_List__c>();
        List<Technical_Checklist__c> lstTechChecklist = new List<Technical_Checklist__c>();
        List<String> lstpoliFieldValue = new List<String>();
        List<String> shippingAddress = new List<String>();
        List<String> billingAddress = new List<String>();
        List<String> chakrShield = new List<String>();
        
        finaSize = [Select Id, Name, PO_Verification__r.Company_Name__c From Financial_Check_List__c Where PO_Verification__c =: recordId ];
        TechSize = [Select Id, Name,PO_Verification__r.Company_Name__c From Technical_Checklist__c Where PO_Verification__c =: recordId ];
        System.debug('Fina List size is ' + finaSize.size());
        System.debug('Tech List size is ' + TechSize.size());
        Povsize = [Select Id, Name, Company_Name__c,Deal__c From PO_Verification__c Where Id =: recordId ];
        System.debug('POV List size is ' + Povsize.size());
        
        Integer RatingSizeCount = 0;
        Integer RatingSizeCount1 = 0;
        Integer RatingSizeCount2 = 0;
        Integer RatingSizeCount3 = 0;
        integer RatingSizeCount4 = 0;
        
        string FinName = 'Financial_Checklist_';
        Integer FinCount = 0;
        string TechName = 'Technical_Checklist_';
        Integer TechCount = 0;
        String AccountName = '';
        if(Povsize[0].Company_Name__c != Null){
            AccountName = Povsize[0].Company_Name__c;
        }
        System.debug('Account Name is ' + AccountName);
        if(finaSize.size()>0)
        {
            FinCount = finaSize.size()+1;
            //AccountName = finaSize[0].PO_Verification__r.Company_Name__c;
        }
        else
        {
            FinCount = 1;
        }
        FinName = AccountName +'_'+FinName + String.valueof(FinCount);
        System.debug('FinName is ' + FinName);
        if(TechSize.size()>0)
        {
            TechCount = TechSize.size()+1;
        }
        else
        {
            TechCount = 1;
        }
        TechName = AccountName +'_'+TechName + String.valueof(TechCount);
        
        for(PO_Verification__c pov : lstpov){
            lstpoli = [Select id,DG_KVA_Rating__c,DG_Make__c,Quantity__c,PO_Verification__c, Shipping_Address__c, Billing_Address__c
                       from PO_Line_Item__c 
                       where PO_Verification__c =: recordId];
            System.debug('poline item size is ' + lstpoli.size());
            
            Financial_Check_List__c fcl = new Financial_Check_List__c();
            /*if (FinName.length() > 80) {
                String nameField = FinName.substring(0, 80);
                fcl.Name = nameField;
            }*/
            fcl.Fin_Full_Name__c = FinName;
            fcl.PO_Verification__c = recordId;
            fcl.GST_Details__c = pov.GST__c;
            fcl.HSN_Code__c = pov.HSN_Code__c;
            fcl.Incoterms__c = pov.Inco_Terms__c;
            fcl.Installation_Timeline_DFK__c = pov.DFK_Installation_Timeline__c;
            fcl.Installation_Timeline_RECD__c = pov.RECD_Installation_Timeline__c;
            fcl.LD_Clause__c = pov.LD_Clause__c;
            fcl.Payment_Terms__c = pov.Payment_Terms__c;
            fcl.Warrenty__c = pov.Warranty__c;
            fcl.Delivery_Timeline_DFK__c = pov.DFK_Delivery_Timeline__c;
            fcl.Delivery_Timeline_RECD__c = pov.RECD_Delivery_Timeline__c; 
            fcl.Selling_Price_variation__c = 'As per PO: ' + pov.PO__c + ',Overall Discount of '+ pov.Average_Discount_Provided__c +'% has been approved by '+ pov.Discount_Hike_LOI_Approver__c;
            insertlstfcl.add(fcl);
            
            Technical_Checklist__c tc = new Technical_Checklist__c();
            /*if (TechName.length() > 80) {
                String nameFieldTech = TechName.substring(0, 80);
                tc.Name = nameFieldTech;
            }*/
            tc.Tech_Full_Name__c = TechName;
            tc.PO_Verification__c = recordId; 
            //Client Detail
            tc.Company_name_End_Client__c = pov.Company_Name__c;
            //tc.Company_Billing_Address__c = pov.Billing_Address__c;
            //tc.Company_Shipping_Address__c = pov.Shipping_Address__c;
            tc.Contact_person_of_end_client__c = pov.End_Client_PoC_Name__c;
            tc.Contact_number_of_end_client__c = pov.End_Client_PoC_Number__c;
            tc.E_Mail_ID_of_contact_person_end_client__c = pov.End_Client_PoC_Email__c;
            //Channel Partner
            tc.Company_name_Channel_Parther_Sales__c = pov.Channel_Partner_Company__c;
            tc.Company_Address_Bill_To_Address_of_chan__c = pov.Channel_Partner_Address__c;
            tc.Contact_person_of_Channel_Partner__c = pov.Channel_Partner_PoC_Name__c;
            tc.Contact_number_of_Channel_Partner__c = String.valueOf(pov.Channel_Partner_PoC_Number__c);
            tc.E_Mail_ID_of_contact_person_of_Channel__c = pov.Channel_Partner_PoC_Email__c;
            tc.All_orders_will_be_processed_against_aut__c='CFO';
            //Technical Specification
            if(!lstpoli.isEmpty()){
                for(PO_Line_Item__c poli : lstpoli){
                    lstpoliFieldValue.add(poli.DG_KVA_Rating__c +' x '+poli.Quantity__c + '-'+ poli.DG_Make__c);
                    shippingAddress.add(poli.Shipping_Address__c);
                    billingAddress.add(poli.Billing_Address__c);
                }
            }
            System.debug('lstpoliFieldValue of string value is ' + lstpoliFieldValue);
            if(!lstpoliFieldValue.isEmpty()){
                tc.Engine_capacity_kW_kVA_rating_on_PO__c = String.join(lstpoliFieldValue, '\n');
            }
            if(pov.Chakr_Shield_2_0_M1__c != null && pov.Chakr_Shield_2_0_M1__c != 0){
                chakrShield.add('Chakr Shield 2.0 M1 : '+pov.Chakr_Shield_2_0_M1__c);
            }
            if(pov.Chakr_Shield_2_0_M2__c != null && pov.Chakr_Shield_2_0_M2__c != 0){
                chakrShield.add('Chakr Shield 2.0 M2 : '+pov.Chakr_Shield_2_0_M2__c);
            }
            if(pov.Chakr_Shield_2_0_M3__c != null && pov.Chakr_Shield_2_0_M3__c != 0){
                chakrShield.add('Chakr Shield 2.0 M3 : '+pov.Chakr_Shield_2_0_M3__c);
            }
            if(pov.Chakr_Shield_2_0_M4__c != null && pov.Chakr_Shield_2_0_M4__c != 0){
                chakrShield.add('Chakr Shield 2.0 M4 : '+pov.Chakr_Shield_2_0_M4__c);
            }
            tc.Model_type_and_quantity__c = String.join(chakrShield,'\n');
            if(!lstpoli.isEmpty()){
                for(PO_Line_Item__c poli : lstpoli){
                    if(poli.DG_KVA_Rating__c > 62 && poli.DG_KVA_Rating__c < 1000){
                        RatingSizeCount ++;
                    }
                }
            }
            if(RatingSizeCount > 0){
                tc.Type_approval_certificate_requested_by_c__c = 'Required';
            }
            else{
                tc.Type_approval_certificate_requested_by_c__c = 'Not Applicable';
            }
            tc.Test_report_certificate_by_CPCB_labs_for__c = pov.DG_Rating__c;
            //tc.No_specification_of_the_specific_MoC_M__c = pov.  ;
            //tc.Type_of_fuel_used_should_be_less_in_sul__c = pov.  ;
            
            //Delivery Timeline 
            if(!lstpoli.isEmpty()){
                for(PO_Line_Item__c poli : lstpoli){
                    if(poli.DG_KVA_Rating__c < 1000){ // If Rating is less than 1000 KVA
                        RatingSizeCount1 ++;
                        System.debug('Less than 1000'+RatingSizeCount1);
                    }	
                    else  if(poli.DG_KVA_Rating__c >= 1000){ //If rating more than 1000 KVA
                        RatingSizeCount2 ++;
                        System.debug('Greater than 1000'+RatingSizeCount2);
                    }
                }
            }		
            if(RatingSizeCount1 > 0){
                tc.For_less_than_1000kVA_6_8_weeks_from_th__c = pov.RECD_Delivery_Timeline__c;
            }
            
            if(RatingSizeCount2 > 0){
                tc.For_greater_than_1000kVA_8_10_weeks_fro__c = pov.RECD_Installation_Timeline__c;
                tc.Tentative_installation_timeline_2_3_week__c = pov.RECD_Installation_Timeline__c;
                
            }
            
            if(RatingSizeCount1 > 0 && RatingSizeCount2 < 0){
                tc.For_greater_than_1000kVA_8_10_weeks_fro__c = pov.RECD_Installation_Timeline__c;
                tc.For_less_than_1000kVA_6_8_weeks_from_th__c = pov.RECD_Delivery_Timeline__c;
            }
            
            //Installation Details
            if(!lstpoli.isEmpty()){
                for(PO_Line_Item__c poli : lstpoli){
                    if(poli.DG_KVA_Rating__c < 500){ // If Rating is less than 1000 KVA
                        RatingSizeCount3 ++;
                        System.debug('Less than 500'+RatingSizeCount3);
                    }	
                    else  if(poli.DG_KVA_Rating__c >=500 && poli.DG_KVA_Rating__c<1000){ //If rating more than 1000 KVA
                        RatingSizeCount4 ++;
                        System.debug('Greater 500 and less than 1000'+RatingSizeCount4);
                    }
                }
            }
            
            if(RatingSizeCount3 >0){
                tc.Tentative_installation_timeline_1_week__c=pov.RECD_Installation_Timeline__c;
            }
            if(RatingSizeCount4 >0){
                tc.Tentative_installation_timeline_2_week__c = pov.RECD_Installation_Timeline__c;
            }
            //tc.Approval_From_the client = 
            //tc.Special_requirements_for_installation__c = pov. ;
            //tc.standard_approval_is_required = 
            tc.DOFF_Scope__c = pov.DOFF__c;
            tc.Piping_and_Structure_Scope__c = pov.Piping_and_Structure__c;
            tc.GA_Drawing_Scope__c = pov.GA_Drawing__c;
            tc.Incoterms__c = pov.Inco_Terms__c;
            tc.Transportation_scope_Client_Chakr__c = pov.Transportation__c;
            tc.Unloading_Scope_Client_Chakr__c = pov.Unloading__c;
            tc.Cladding_Scope_Client_Chakr__c = pov.Cladding__c;
            if(pov.Channel_Partner_Involved__c=='Yes' && pov.Supervision_Required__c=='Yes')
            {
                tc.Installation_Supervision_If_required_f__c =string.valueof(pov.Supervision_Charges_per_day_per_DG__c) ;
            }
            tc.NABL_Testing_PM_reduction_Client_Chakr__c = pov.NABL_PM__c;
            tc.NABL_Testing_HC_CO_reduction_Client__c = pov.NABL_PM_HC_CO__c;
            tc.Commissioning_and_CR_Signoff__c = pov.Comissioning_and_CR_Signoff__c;
            //Department Enquiries
            //tc.All_orders_will_be_processed_against_aut__c = ;
            tc.If_LD_Liquidity_Damages_applicable__c = pov.LD_Clause__c;
            tc.Special_Remarks_If_Any__c = pov.Special_Remarks_RECD__c;
            for(String sts : shippingAddress){
                if(tc.Company_Shipping_Address__c != Null){
                    tc.Company_Shipping_Address__c += '➣ '+sts + '\n\n';
                }else if(sts != Null){
                    tc.Company_Shipping_Address__c = '➣ '+sts + '\n\n';
                }
            }
            for(String stb : billingAddress){
                if(tc.Company_Billing_Address__c != Null){
                    tc.Company_Billing_Address__c += '➣ '+stb + '\n\n';
                }else if(stb != Null){
                    tc.Company_Billing_Address__c = '➣ '+stb + '\n\n';
                }
            }
            lstTechChecklist.add(tc);
        }
        if(!insertlstfcl.isEmpty()){
            insert insertlstfcl;
        }
        System.debug('financial check list is 3'+ insertlstfcl);
        
        if(!lstTechChecklist.isEmpty()){
            insert lstTechChecklist;
        }
        System.debug('Technical check list is 3'+ lstTechChecklist);
        //return insertlstfcl[0].Id;
        //return lstTechChecklist[0].Id;
        
    }
    
    @AuraEnabled
    public static Boolean getCheckListRecords(Id recordId){
        System.debug('record id is ' + recordId);
        
        List<Financial_Check_List__c> finaSize = [Select Id, Name, PO_Verification__r.Company_Name__c From Financial_Check_List__c Where PO_Verification__c =: recordId ];
        List<Technical_Checklist__c> TechSize = [Select Id, Name, PO_Verification__r.Company_Name__c From Technical_Checklist__c Where PO_Verification__c =: recordId ];
        System.debug('Fina List size is ' + finaSize.size());
        System.debug('Tech List size is ' + TechSize.size());
        
        if(!finaSize.isEmpty() || !TechSize.isEmpty()){
            return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static Boolean checkLineItem(Id recordId){
        List<PO_Line_Item__c> lstpoli = new List<PO_Line_Item__c>();
        
        List<PO_Line_Item__c> lineItemCount = [SELECT id FROM PO_Line_Item__c WHERE PO_Verification__c = :recordId];
        System.debug('line item count is ' + lineItemCount);
        
        List<Milestone__c> milestoneCount = [SELECT id FROM Milestone__c WHERE PO_Verification__c = :recordId];
        System.debug('milestoneCount count is ' + milestoneCount);
        if(!lineItemCount.isEmpty() && !milestoneCount.isEmpty()){
            return true;
        }
        return false;
    }
}