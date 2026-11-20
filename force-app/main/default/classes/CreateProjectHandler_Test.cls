@isTest
public class CreateProjectHandler_Test {
    public static testmethod void m1() {

        PO_Verification__c pov = new PO_Verification__c();
        pov.BP_Code__c = 'TEST123';
        insert pov;
        
        PO_Line_Item__c poli = new PO_Line_Item__c();
        poli.PO_Verification__c = pov.Id;
        poli.Quantity__c = 1;
        insert poli;
        
        Financial_Check_List__c finance = new Financial_Check_List__c();
        finance.PO_Verification__c = pov.Id;
        insert finance;
        
        Technical_Checklist__c technical = new Technical_Checklist__c();
        technical.PO_Verification__c = pov.Id;
        insert technical;

        // Prepare projectRows
        List<Map<String, Object>> projectRows = new List<Map<String, Object>>();
        Map<String, Object> row = new Map<String, Object>();
        row.put('rowIndex', 1);
        row.put('recordType', 'Inhouse');
        projectRows.add(row);

        Test.startTest();
        CreateProjectHandler.createProjectRecord(pov.Id, projectRows);
        CreateProjectHandler.getProjectPreview(pov.id);
        CreateProjectHandler.getProjectRecord(pov.Id);
        CreateProjectHandler.checkLineItem(pov.Id);
        CreateProjectHandler.checkFinancialCheckList(pov.Id);
        CreateProjectHandler.checkTechnicalCheckList(pov.Id);
        Test.stopTest();
    }

    // Test method to verify Chakr Marjak PO Verification creates Chakr Marjak project -- Added by Vanshika 20-Nov-2026
    @isTest
    public static void testChakrMarjak() {
        Map<String, Schema.RecordTypeInfo> povRtMap = Schema.SObjectType.PO_Verification__c.getRecordTypeInfosByDeveloperName();
        Id chakrMarjakPovRtId = povRtMap.containsKey('Chakr_Marjak') ? povRtMap.get('Chakr_Marjak').getRecordTypeId() : null;

        PO_Verification__c pov = new PO_Verification__c();
        pov.BP_Code__c = 'CHAKR123';
        if (chakrMarjakPovRtId != null) {
            pov.RecordTypeId = chakrMarjakPovRtId;
        }
        insert pov;
        
        PO_Line_Item__c poli = new PO_Line_Item__c();
        poli.PO_Verification__c = pov.Id;
        poli.Quantity__c = 1;
        insert poli;
        
        Financial_Check_List__c finance = new Financial_Check_List__c();
        finance.PO_Verification__c = pov.Id;
        insert finance;
        
        Technical_Checklist__c technical = new Technical_Checklist__c();
        technical.PO_Verification__c = pov.Id;
        insert technical;

        Test.startTest();
        List<Map<String, Object>> previewRows = CreateProjectHandler.getProjectPreview(pov.Id);
        System.assertNotEquals(0, previewRows.size(), 'Preview rows should be generated');

        if (chakrMarjakPovRtId != null) {
            System.assertEquals(true, previewRows[0].get('isChakrMarjak'), 'Should detect Chakr_Marjak');
            System.assertEquals('Chakr_Marjak', previewRows[0].get('recordType'), 'Default record type should be Chakr_Marjak');
        }

        CreateProjectHandler.createProjectRecord(pov.Id, previewRows);
        Test.stopTest();

        List<Project__c> createdProjects = [SELECT Id, RecordType.DeveloperName FROM Project__c WHERE PO_Verification__c = :pov.Id];
        System.assertEquals(1, createdProjects.size(), 'One project should be created');
        if (chakrMarjakPovRtId != null) {
            System.assertEquals('Chakr_Marjak', createdProjects[0].RecordType.DeveloperName, 'Project record type should be Chakr_Marjak');
        }
    }
}
