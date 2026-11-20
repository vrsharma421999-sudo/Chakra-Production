/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : ContractUnoPoint
 * Author          : Shubhanshu
 * Created Date    : Feb 20, 2026
 * Last Modified By: Shubhanshu
 * Last Modified On: Feb 23, 2026
 * Description     : 	
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
public class ContractUnoPoint {

    @future(callout=true)
    public static void SyncContractLineItems(Set<Id> recordIds) {
        System.debug('SyncContractLineItems called with IDs: ' + recordIds);

        List<Contract_Line_Item__c> listItems = [
            SELECT Id, Name, RECD_Serial_No__c, Contract_Start_Date__c, Contract_End_Date__c, Contract__r.Name,
                   Shipping_Address__c, KVA_Rating__c, PO_Line_Item__c, PO_Line_Item__r.Name,
                   // PO Verification fields
                   Contract__r.PO_Verification__c,
                   Contract__r.PO_Verification__r.End_Client_PoC_Email__c,
                   Contract__r.PO_Verification__r.End_Client_PoC_Name__c,
                   Contract__r.PO_Verification__r.End_Client_PoC_Number__c,
                   Contract__r.PO_Verification__r.PO__c,
                   Contract__r.PO_Verification__r.PO_Full_Name__c,
                   // Delivery location
                   Contract__r.Deal__r.Account.BillingState,
                   Contract__r.Deal__r.Account.BillingCity,
                   Contract__r.Deal__r.City__c,
                   Contract__r.Deal__r.State__c
            FROM Contract_Line_Item__c
            WHERE Id IN :recordIds
        ];

        if (listItems.isEmpty()) return;

        Set<Id> dealIds = new Set<Id>();

for (Contract_Line_Item__c item : listItems) {
    if (item.Contract__r.Deal__c != null) {
        dealIds.add(item.Contract__r.Deal__c);
    }
}

        Map<Id, Project__c> dealToProjectMap = new Map<Id, Project__c>();

if (!dealIds.isEmpty()) {
    for (Asset__c asset : [ SELECT Id, Deal__c,
               Project__r.Id,
               Project__r.Name,
               Project__r.Model_Type__c,
               Project__r.Deliver_State__c,
               Project__r.Delivery_City__c,
               Project__r.Prod__c,
               Project__r.Commissioning_Status__c,
               Project__r.Installation_Status__c,
               Project__r.QC_status__c
        FROM Asset__c
        WHERE Deal__c IN :dealIds
    ]) {
        if (asset.Project__c != null && !dealToProjectMap.containsKey(asset.Deal__c))  {
            dealToProjectMap.put(asset.Deal__c, asset.Project__r);
            System.debug('Asset Project is -->'+Asset.Project__r.Name);
        }
    }
}

        List<Contract_Line_Item__c> itemsToUpdate = new List<Contract_Line_Item__c>();

        for (Contract_Line_Item__c item : listItems) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:UNO_Chakr_API');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            Project__c relatedProject =dealToProjectMap.get(item.Contract__r.Deal__c);

            Map<String, Object> payload = new Map<String, Object>{
                'recd_Sr_No__c'                 => item.RECD_Serial_No__c,
                'name'                          => item.Contract__r.Name,
                'installation_Complete_Date__c' => item.Contract_Start_Date__c != null ? String.valueOf(item.Contract_Start_Date__c) : null,
                'principleWarrantyStartDate'    => item.Contract_Start_Date__c != null ? String.valueOf(item.Contract_Start_Date__c) : null,
                'principleWarrantyEndDate'      => item.Contract_End_Date__c   != null ? String.valueOf(item.Contract_End_Date__c)   : null,
                'deliver_State__'               => relatedProject != null && relatedProject.Deliver_State__c != null ? relatedProject.Deliver_State__c : null,
                'deliver_City__c'               => relatedProject != null && relatedProject.Delivery_City__c != null ? relatedProject.Delivery_City__c : null,
                'customerAddress'               => item.Shipping_Address__c,
                'end_Client_POC_Email__c'       => item.Contract__r.PO_Verification__r.End_Client_PoC_Email__c,
                'end_Client_POC_Name__c'        => item.Contract__r.PO_Verification__r.End_Client_PoC_Name__c,
                'end_Client_POC__c'             => item.Contract__r.PO_Verification__r.End_Client_PoC_Number__c,
                'project_Full_Name__c'          => item.Contract__r.Name,
                'prod__c'                       => relatedProject != null ? relatedProject.Prod__c : null,
                'model_Type__c'                 => relatedProject != null && relatedProject.Model_Type__c != null ? relatedProject.Model_Type__c : null,
                'popLocation'                   => relatedProject != null && relatedProject.Delivery_City__c != null ? relatedProject.Delivery_City__c : null,
                'crSignedDate'                  => item.Contract_Start_Date__c != null ? String.valueOf(item.Contract_Start_Date__c) : null,
                'commissioning_Status__c'       => relatedProject != null && relatedProject.Commissioning_Status__c != null ? relatedProject.Commissioning_Status__c : null,
                'installation_Status__c'        => relatedProject != null && relatedProject.Installation_Status__c != null ? relatedProject.Installation_Status__c : null,
                'po_Verification__c'            => 'Verified',
                'po_Line_Item__c'               => item.PO_Line_Item__r.Name,
                'po_Number__c'                  => item.Contract__r.PO_Verification__r.PO__c,
                'field_Quality_Approved_Date__c'=> item.Contract_Start_Date__c != null ? String.valueOf(item.Contract_Start_Date__c) : null,
                'qc_status__c'                  => relatedProject != null && relatedProject.QC_status__c != null ? relatedProject.QC_status__c : null,
                'kva_Rating__c'                 => item.KVA_Rating__c != null ? String.valueOf(item.KVA_Rating__c.intValue()) : null
            };

            String body = JSON.serialize(payload);
            System.debug('Payload Body: ' + body);
            req.setBody(body);

            Http http = new Http();
            try {
                HttpResponse res = http.send(req);
                System.debug('UNO API Response Code: ' + res.getStatusCode());
                System.debug('UNO API Response Body: ' + res.getBody());
                if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                    item.Sync_Uno_Point__c = true;
                    item.Sync_Error_Message__c = null;
                } else {
                    item.Sync_Uno_Point__c = false;
                    String errMsg = 'Code: ' + res.getStatusCode() + ' | Body: ' + res.getBody();
                    item.Sync_Error_Message__c = errMsg.length() > 255 ? errMsg.substring(0, 255) : errMsg;
                }
            } catch (Exception e) {
                item.Sync_Uno_Point__c = false;
                item.Sync_Error_Message__c = e.getMessage();
            }
            itemsToUpdate.add(item);
        }

        if (!itemsToUpdate.isEmpty()) {
            update itemsToUpdate;
        }
    }
}