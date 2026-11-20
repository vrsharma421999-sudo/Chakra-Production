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
}


/*@isTest
public class CreateProjectHandler_Test {
    public static testmethod void m1()
    {
        PO_Verification__c pov = new PO_Verification__c();
        insert pov;
        
        PO_Line_Item__c poli = new PO_Line_Item__c();
        poli.PO_Verification__c = pov.Id;
        poli.Quantity__c = 4;
        insert poli;
        
        Financial_Check_List__c finance = new Financial_Check_List__c();
        finance.PO_Verification__c = pov.Id;
        insert finance;
        
        Technical_Checklist__c technical = new Technical_Checklist__c();
        technical.PO_Verification__c = pov.Id;
        insert technical;
        
        Project__c pro = new Project__c();
        pro.PO_Verification__c = pov.Id;
        //pro.OwnerId = '005Rt00000FHVCCIA5';
        insert pro;
        
        CreateProjectHandler.createProjectRecord(pov.Id);
        CreateProjectHandler.getProjectRecord(pov.Id);
        CreateProjectHandler.checkLineItem(pov.Id);
        CreateProjectHandler.checkFinancialCheckList(pov.Id);
        CreateProjectHandler.checkTechnicalCheckList(pov.Id);
    }
}*/