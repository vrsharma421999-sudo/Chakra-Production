@isTest
public class CreateFinancialCheckListHandler_Test {
    public static testmethod void m1(){
        test.startTest();
        PO_Verification__c pov = new PO_Verification__c();
        pov.BP_Code__c = 'TEST123';
        insert pov;
        
        PO_Line_Item__c poli = new PO_Line_Item__c();
        poli.PO_Verification__c = pov.id;
        insert poli;
        
        Financial_Check_List__c fcl = new Financial_Check_List__c();
        fcl.PO_Verification__c = pov.Id;
        insert fcl;
        CreateFinancialCheckListHandler.createFinancialCheckList(pov.Id);
        CreateFinancialCheckListHandler.getCheckListRecords(pov.Id);
        CreateFinancialCheckListHandler.checkLineItem(pov.Id);
        test.stopTest();
    }
}