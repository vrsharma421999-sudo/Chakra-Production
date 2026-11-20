/* @AUTHOR       : Nikki Pandey
 * @DESCRIPTION  : On button click create project record
 * @CREATEDATE   : 6-JAN-2025
 * @MODIFIED BY  : Nikhil Kumar Varun
 * @MODIFIEDDATE : 21-Feb-2025
 */

public class CreateProjectHandler {

    // ─── PREVIEW (no DML) ───────────────────────────────────────────────────
    @AuraEnabled
    public static List<Map<String, Object>> getProjectPreview(Id recordId) {
        List<PO_Line_Item__c> pliList = [
            SELECT Id, Name, Quantity__c, DG_KVA_Rating__c, Panel_Type__c
            FROM PO_Line_Item__c
            WHERE PO_Verification__c = :recordId
        ];

        List<Map<String, Object>> previewList = new List<Map<String, Object>>();
        PO_Verification__c pov = [
            SELECT Id, Deal__r.Name
            FROM PO_Verification__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        Integer prCount = [SELECT COUNT() FROM Project__c WHERE PO_Verification__c = :recordId] + 1;

        for (PO_Line_Item__c pli : pliList) {
            for (Integer i = 0; i < (Integer) pli.Quantity__c; i++) {
                Map<String, Object> row = new Map<String, Object>();
                String prName = pov.Deal__r.Name + '_PR ' + prCount;
                if (prName.length() > 80) {
                    prName = prName.substring(0, 80);
                }
                row.put('projectName', prName);
                row.put('kvaRating', pli.DG_KVA_Rating__c);
                row.put('panelType', pli.Panel_Type__c);
                row.put('pliId', pli.Id);
                row.put('rowIndex', prCount);
                previewList.add(row);
                prCount++;
            }
        }
        return previewList;
    }

    // ─── CREATE (with DML) ──────────────────────────────────────────────────
    @AuraEnabled
    public static void createProjectRecord(Id recordId, List<Map<String, Object>> projectRows) {
        // ── Validation checks ──
        List<PO_Line_Item__c> lineItems = [SELECT Id FROM PO_Line_Item__c WHERE PO_Verification__c = :recordId];
        if (lineItems.isEmpty()) {
            throw new AuraHandledException('PO Line Item with Technical and Financial checklist should be present to create project.');
        }

        List<Financial_Check_List__c> finList = [SELECT Id FROM Financial_Check_List__c WHERE PO_Verification__c = :recordId];
        if (finList.isEmpty()) {
            throw new AuraHandledException('PO Line Item with Technical and Financial checklist should be present to create project.');
        }

        List<Technical_Checklist__c> techList = [SELECT Id, CreatedDate FROM Technical_Checklist__c WHERE PO_Verification__c = :recordId];
        if (techList.isEmpty()) {
            throw new AuraHandledException('PO Line Item with Technical and Financial checklist should be present to create project.');
        }

        List<Project__c> existingProjects = [SELECT Id FROM Project__c WHERE PO_Verification__c = :recordId];
        if (!existingProjects.isEmpty()) {
            throw new AuraHandledException('Project records already exist for this PO Verification.');
        }

        // ── Fetch supporting data ──
        PO_Verification__c pov = [
            SELECT Id, Name, PO__c, Total_Chakr_Shield_Quantity__c, Deal__c,
                   Deal__r.Name, Deal__r.Chakr_Shield_Model__c, Deal__r.City__c,
                   Deal__r.State__c, Deal__r.TotalOpportunityQuantity, Deal__r.Rating__c,
                   Deal__r.Installation__c, Deal__r.Transportation__c,
                   Transportation_Per_Unit__c, Installation_Per_Unit__c
            FROM PO_Verification__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        List<PO_Line_Item__c> pliList = [
            SELECT Id, Name, Quantity__c, PO_Verification__c, Device_per_unit__c,
                   Panel_Type__c, PO_Verification__r.Name, DG_KVA_Rating__c,
                   Installation_Per_Unit__c, Transportation_Per_Unit__c,
                   Additional_Cost__c, Supervision_Cost__c
            FROM PO_Line_Item__c
            WHERE PO_Verification__c = :recordId
        ];

        User pmUser = [SELECT Id, Email FROM User WHERE Profile.Name = 'PM Head' AND PM_Head__c = true AND IsActive = TRUE LIMIT 1];

        // ── Fetch Record Type Ids ──
        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Project__c' AND DeveloperName IN ('Inhouse', 'Outsource')]) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }

        // ── Build a map of rowIndex → recordType from the passed rows ──
        Map<Integer, String> rowRecordTypeMap = new Map<Integer, String>();
        for (Map<String, Object> row : projectRows) {
            Integer rowIndex = Integer.valueOf(String.valueOf(row.get('rowIndex')));
            String recType = String.valueOf(row.get('recordType'));
            rowRecordTypeMap.put(rowIndex, recType);
        }

        // ── Build project records ──
        List<Project__c> lstpro = new List<Project__c>();
        Integer prCount = existingProjects.size() + 1;
        Integer age = techList[0].CreatedDate.date().daysBetween(Date.today());

        for (PO_Line_Item__c pli : pliList) {
            for (Integer i = 0; i < (Integer) pli.Quantity__c; i++) {
                String prName = pov.Deal__r.Name + '_PR ' + prCount;
                if (prName.length() > 80) {
                    prName = prName.substring(0, 80);
                }

                String selectedRecordType = rowRecordTypeMap.containsKey(prCount) ? rowRecordTypeMap.get(prCount) : 'Inhouse';
                Id recordTypeId = rtMap.containsKey(selectedRecordType) ? rtMap.get(selectedRecordType) : rtMap.get('Inhouse');

                Project__c pro = new Project__c();
                pro.RecordTypeId      = recordTypeId;
                pro.OwnerId           = pmUser.Id;
                pro.Name              = prName;
                pro.Project_Full_Name__c = prName;
                pro.PO_Line_Item__c   = pli.Id;
                pro.PO_Verification__c = recordId;
                pro.Deal__c           = pov.Deal__c;
                pro.Panel_Type__c     = pli.Panel_Type__c;
                pro.Model_Type__c     = pov.Deal__r.Chakr_Shield_Model__c;
                pro.Delivery_City__c  = pov.Deal__r.City__c;
                pro.Deliver_State__c  = pov.Deal__r.State__c;
                pro.PO_Number__c      = pov.PO__c;
                pro.Quantity__c       = pov.Total_Chakr_Shield_Quantity__c;
                pro.KVA_Rating__c     = pli.DG_KVA_Rating__c;
                pro.Supply__c         = pli.Device_per_unit__c;
                pro.Installation__c   = pli.Installation_Per_Unit__c;
                pro.Transportation__c = pli.Transportation_Per_Unit__c;
                pro.PO_Date__c        = Date.today();
                pro.Additional_Cost__c = pli.Additional_Cost__c;
                pro.Supervision_Cost__c = pli.Supervision_Cost__c;
                pro.Ageing__c         = age;
                lstpro.add(pro);
                prCount++;
            }
        }

        if (!lstpro.isEmpty()) {
            insert lstpro;

            // ── Email notification ──
            List<User> lstEmailUsers = [SELECT Email FROM User WHERE ProfileId = '00eUz00000BDlu2' AND IsActive = TRUE];
            List<String> ccEmails = new List<String>();
            for (User u : lstEmailUsers) {
                ccEmails.add(u.Email);
            }
            ccEmails.add('amit.aseri@chakr.in');

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{ pmUser.Email });
            mail.setCcAddresses(ccEmails);
            mail.setSubject('Project has been created for - ' + pov.Name);
            mail.setPlainTextBody(
                'Hi,' +
                '\nProject for PO Verification ' + pov.Name + ' has been created.' +
                '\nhttps://chakrinnovation.lightning.force.com/lightning/r/PO_Verification__c/' + recordId + '/view'
            );
            //Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        }
    }

    @AuraEnabled
    public static Boolean getProjectRecord(Id recordId) {
        return ![SELECT Id FROM Project__c WHERE PO_Verification__c = :recordId].isEmpty();
    }

    @AuraEnabled
    public static Boolean checkLineItem(Id recordId) {
        return ![SELECT Id FROM PO_Line_Item__c WHERE PO_Verification__c = :recordId].isEmpty();
    }

    @AuraEnabled
    public static Boolean checkFinancialCheckList(Id recordId) {
        return ![SELECT Id FROM Financial_Check_List__c WHERE PO_Verification__c = :recordId].isEmpty();
    }

    @AuraEnabled
    public static Boolean checkTechnicalCheckList(Id recordId) {
        return ![SELECT Id FROM Technical_Checklist__c WHERE PO_Verification__c = :recordId].isEmpty();
    }
}