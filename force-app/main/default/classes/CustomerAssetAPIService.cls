public class CustomerAssetAPIService {

    @future(callout=true)
    public static void CreateAssetFromUNOPoint(Set<Id> recordIds) {
        Date RECDDate;
        List<Project__c> listProject = [
            SELECT Id, RECD_Sr_No__c, Name,
                   installation_Complete_Date__c,
                   Comissioning_CR_Signoff__c,
                   Client_RECD_Received_Date__c,
                   Warranty_Start_Date__c,
                   Warranty_End_Date__c,
                   deliver_State__c,
                   Delivery_City__c,
                   PO_Line_Item__r.Shipping_Address__c,
                   end_Client_POC_Email__c,
                   end_Client_POC_Name__c,
                   end_Client_POC__c,
                   project_Full_Name__c,
                   model_Type__c,
                   CR_Signed_Date__c,
                   commissioning_Status__c,
                   installation_Status__c,
                   po_Verification__c,
                   po_Line_Item__c,
                   po_Number__c,
                   field_Quality_Approved_Date__c,
                   qc_status__c,
                   kva_Rating__c,
                   Prod__c
            FROM Project__c
            WHERE Id IN :recordIds
        ];

        for (Project__c ObjProject : listProject) {

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:UNO_Chakr_API');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            if(ObjProject.Comissioning_CR_Signoff__c != null && ObjProject.Comissioning_CR_Signoff__c=='Chakr'){
                RECDDate=ObjProject.Warranty_Start_Date__c;
            }
            else{
                RECDDate=ObjProject.Client_RECD_Received_Date__c;
            }

            Map<String, Object> payload = new Map<String, Object>{
                'recd_Sr_No__c' => ObjProject.RECD_Sr_No__c,
                'name' => ObjProject.Name,
                'installation_Complete_Date__c' => ObjProject.installation_Complete_Date__c != null ? String.valueOf(ObjProject.installation_Complete_Date__c) : null,
                'principleWarrantyStartDate' => RECDDate != null ? String.valueOf(RECDDate) : null,
                'principleWarrantyEndDate' => ObjProject.Warranty_End_Date__c != null ? String.valueOf(ObjProject.Warranty_End_Date__c) : null,
                'deliver_State__' => ObjProject.deliver_State__c,
                'deliver_City__c' => ObjProject.Delivery_City__c,
                'customerAddress' => ObjProject.PO_Line_Item__r.Shipping_Address__c,
                'end_Client_POC_Email__c' => ObjProject.end_Client_POC_Email__c,
                'end_Client_POC_Name__c' => ObjProject.end_Client_POC_Name__c,
                'end_Client_POC__c' => ObjProject.end_Client_POC__c,
                'project_Full_Name__c' => ObjProject.project_Full_Name__c,
                'prod__c' => ObjProject.Prod__c,
                'model_Type__c' => ObjProject.model_Type__c,
                'popLocation' => ObjProject.Delivery_City__c,
                'crSignedDate' => ObjProject.CR_Signed_Date__c != null ? String.valueOf(ObjProject.CR_Signed_Date__c) : null,
                'commissioning_Status__c' => ObjProject.commissioning_Status__c,
                'installation_Status__c' => ObjProject.installation_Status__c,
                'po_Verification__c' => ObjProject.po_Verification__c,
                'po_Line_Item__c' => ObjProject.po_Line_Item__c,
                'po_Number__c' => ObjProject.po_Number__c,
                'field_Quality_Approved_Date__c' => ObjProject.field_Quality_Approved_Date__c != null ? String.valueOf(ObjProject.field_Quality_Approved_Date__c) : null,
                'qc_status__c' => ObjProject.qc_status__c,
                'kva_Rating__c' => ObjProject.kva_Rating__c != null ? String.valueOf(ObjProject.kva_Rating__c) : null
            };
            System.debug('Payload Map: ' + payload);
            System.debug('Payload JSON: ' + JSON.serialize(payload));


            req.setBody(JSON.serialize(payload));

            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('Status Code: ' + res.getStatusCode());
System.debug('Status: ' + res.getStatus());
System.debug('Response Body: ' + res.getBody());

            if (res.getStatusCode() == 200) {
                ObjProject.Sync_UNO_Point__c = true;
            } else {
                ObjProject.Sync_UNO_Point__c = false;
            }
        }

        update listProject;
    }
}