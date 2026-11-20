/* @AUTHOR       : Nikki Pandey
 * @DESCRIPTION  : On button click create project record
 * @CREATEDATE   : 6-JAN-2025
 * @MODIFIED BY  : Nikhil Kumar Varun, Vanshika Raj
 * @MODIFIEDDATE : 20-Nov-2026
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
        // Query RecordType for PO Verification and Deal to detect Chakr Marjak -- By Vanshika 20-Nov-2026
        PO_Verification__c pov = [
            SELECT Id, Name, Deal__r.Name, RecordType.DeveloperName, Deal__r.RecordType.DeveloperName
            FROM PO_Verification__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        // Auto-detect Chakr Marjak and set default record type -- By Vanshika 20-Nov-2026
        Boolean isChakrMarjak = (pov.RecordType != null && pov.RecordType.DeveloperName == 'Chakr_Marjak')
            || (pov.Deal__r != null && pov.Deal__r.RecordType != null && pov.Deal__r.RecordType.DeveloperName == 'Chakr_Marjak');
        String defaultRT = isChakrMarjak ? 'Chakr_Marjak' : 'Inhouse';

        Integer prCount = [SELECT COUNT() FROM Project__c WHERE PO_Verification__c = :recordId] + 1;
        String baseName = (pov.Deal__r != null && String.isNotBlank(pov.Deal__r.Name)) ? pov.Deal__r.Name : pov.Name;

        for (PO_Line_Item__c pli : pliList) {
            Integer qty = (pli.Quantity__c != null && pli.Quantity__c > 0) ? Integer.valueOf(pli.Quantity__c) : 1;
            String cleanPanelType = null;
            if (String.isNotBlank(pli.Panel_Type__c)) {
                if (pli.Panel_Type__c.contains('Smart Panel')) {
                    cleanPanelType = 'Smart Panel';
                } else if (pli.Panel_Type__c.contains('Regular Panel')) {
                    cleanPanelType = 'Regular Panel';
                }
            }

            for (Integer i = 0; i < qty; i++) {
                Map<String, Object> row = new Map<String, Object>();
                String prName = baseName + '_PR ' + prCount;
                if (prName.length() > 80) {
                    prName = prName.substring(0, 80);
                }
                row.put('projectName', prName);
                row.put('kvaRating', pli.DG_KVA_Rating__c);
                row.put('panelType', cleanPanelType);
                row.put('pliId', pli.Id);
                row.put('rowIndex', prCount);
                // Default record type and Chakr Marjak flag for UI -- By Vanshika 20-Nov-2026
                row.put('recordType', defaultRT);
                row.put('isChakrMarjak', isChakrMarjak);
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

        // ── Fetch supporting data (Include RecordTypes for Chakr Marjak check -- By Vanshika 20-Nov-2026) ──
        PO_Verification__c pov = [
            SELECT Id, Name, PO__c, Total_Chakr_Shield_Quantity__c, Deal__c,
                   Deal__r.Name, Deal__r.Chakr_Shield_Model__c, Deal__r.City__c,
                   Deal__r.State__c, Deal__r.TotalOpportunityQuantity, Deal__r.Rating__c,
                   Deal__r.Installation__c, Deal__r.Transportation__c,
                   Transportation_Per_Unit__c, Installation_Per_Unit__c,
                   RecordType.DeveloperName, Deal__r.RecordType.DeveloperName
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

        List<User> pmUsers = [SELECT Id, Email FROM User WHERE Profile.Name = 'PM Head' AND PM_Head__c = true AND IsActive = TRUE LIMIT 1];
        Id pmUserId = !pmUsers.isEmpty() ? pmUsers[0].Id : UserInfo.getUserId();
        String pmUserEmail = !pmUsers.isEmpty() ? pmUsers[0].Email : UserInfo.getUserEmail();

        // ── Fetch Record Type Ids (Included Chakr_Marjak -- By Vanshika 20-Nov-2026) ──
        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Project__c' AND DeveloperName IN ('Inhouse', 'Outsource', 'Chakr_Marjak')]) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }

        // Auto-detect Chakr Marjak for fallback -- By Vanshika 20-Nov-2026
        Boolean isChakrMarjak = (pov.RecordType != null && pov.RecordType.DeveloperName == 'Chakr_Marjak')
            || (pov.Deal__r != null && pov.Deal__r.RecordType != null && pov.Deal__r.RecordType.DeveloperName == 'Chakr_Marjak');
        String defaultFallbackRT = isChakrMarjak ? 'Chakr_Marjak' : 'Inhouse';
        Id fallbackId = rtMap.containsKey(defaultFallbackRT) ? rtMap.get(defaultFallbackRT) : (rtMap.containsKey('Inhouse') ? rtMap.get('Inhouse') : null);

        // ── Build a map of rowIndex → recordType from the passed rows ──
        Map<Integer, String> rowRecordTypeMap = new Map<Integer, String>();
        if (projectRows != null) {
            for (Map<String, Object> row : projectRows) {
                if (row.containsKey('rowIndex') && row.get('rowIndex') != null) {
                    Integer rowIndex = Integer.valueOf(String.valueOf(row.get('rowIndex')));
                    String recType = String.valueOf(row.get('recordType'));
                    rowRecordTypeMap.put(rowIndex, recType);
                }
            }
        }

        // ── Build project records ──
        List<Project__c> lstpro = new List<Project__c>();
        Integer prCount = existingProjects.size() + 1;
        Integer age = (techList[0].CreatedDate != null) ? techList[0].CreatedDate.date().daysBetween(Date.today()) : 0;
        String baseName = (pov.Deal__r != null && String.isNotBlank(pov.Deal__r.Name)) ? pov.Deal__r.Name : pov.Name;

        for (PO_Line_Item__c pli : pliList) {
            Integer qty = (pli.Quantity__c != null && pli.Quantity__c > 0) ? Integer.valueOf(pli.Quantity__c) : 1;
            String cleanPanelType = null;
            if (String.isNotBlank(pli.Panel_Type__c)) {
                if (pli.Panel_Type__c.contains('Smart Panel')) {
                    cleanPanelType = 'Smart Panel';
                } else if (pli.Panel_Type__c.contains('Regular Panel')) {
                    cleanPanelType = 'Regular Panel';
                }
            }

            for (Integer i = 0; i < qty; i++) {
                String prName = baseName + '_PR ' + prCount;
                if (prName.length() > 80) {
                    prName = prName.substring(0, 80);
                }

                // If Chakr Marjak POV, strictly lock to Chakr_Marjak record type -- By Vanshika 20-Nov-2026
                String selectedRecordType = isChakrMarjak ? 'Chakr_Marjak' : (rowRecordTypeMap.containsKey(prCount) ? rowRecordTypeMap.get(prCount) : defaultFallbackRT);
                Id recordTypeId = rtMap.containsKey(selectedRecordType) ? rtMap.get(selectedRecordType) : fallbackId;

                Project__c pro = new Project__c();
                pro.RecordTypeId      = recordTypeId;
                pro.OwnerId           = pmUserId;
                pro.Name              = prName;
                pro.Project_Full_Name__c = prName;
                pro.PO_Line_Item__c   = pli.Id;
                pro.PO_Verification__c = recordId;
                pro.Deal__c           = pov.Deal__c;
                pro.Panel_Type__c     = cleanPanelType;
                pro.Model_Type__c     = (pov.Deal__r != null) ? pov.Deal__r.Chakr_Shield_Model__c : null;
                pro.Delivery_City__c  = (pov.Deal__r != null) ? pov.Deal__r.City__c : null;
                pro.Deliver_State__c  = (pov.Deal__r != null) ? pov.Deal__r.State__c : null;
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
            try {
                insert lstpro;
            } catch (Exception e) {
                AuraHandledException ahe = new AuraHandledException(e.getMessage());
                ahe.setMessage(e.getMessage());
                throw ahe;
            }

            // ── Email notification ──
            List<User> lstEmailUsers = [SELECT Email FROM User WHERE ProfileId = '00eUz00000BDlu2' AND IsActive = TRUE];
            List<String> ccEmails = new List<String>();
            for (User u : lstEmailUsers) {
                ccEmails.add(u.Email);
            }
            ccEmails.add('amit.aseri@chakr.in');

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{ pmUserEmail });
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
