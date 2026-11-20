/* @AUTHOR       : Nikki Pandey
* @DESCRIPTION   : Whenever we create PO Verification record with Deal lookup then all the field
mapped with deal, will populate to the PO Verification record page automatically.

//below code is comment now. we are not creating lineitem. 
also create the PO line item based on the selected Deal's Deal_DG.
* @CREATEDATE    : 03-Feb-2025


* @MODIFIEDDATE : 25-Oct-2025
* @Description	: whenever field ... value has been changed send an email to the all user having profile 
	PM Team and Sales Team will be sent.
*/
trigger POVerificationTrigger on PO_Verification__c (before insert,after insert,before update,after update) {
    
    if(Label.POVerificationTrigger != 'True'){
        return;
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        POVerification_Handler.getData(Trigger.new);
        POVerification_Handler.assignToQueue(Trigger.new);
    }
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        // POVerification_Handler.getDataLineItem(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isInsert){
        POVerification_Handler.povNaming(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        POVerification_Handler.StageChangeError(Trigger.new, Trigger.oldMap);
        POVerification_Handler.approvalProcess(Trigger.new, Trigger.oldMap);
        POVerification_Handler.UpdateOwner(Trigger.new, Trigger.oldMAp);
    }
    if(Trigger.isAfter && Trigger.isUpdate) {
        POVerification_Handler.ChangeOwner(Trigger.new, Trigger.oldMAp);
        POVerification_Handler.sendEmailToPMTeamAndSalesTeam(Trigger.new, Trigger.oldMap);
        POVerification_Handler.updateMilestoneAmounts(Trigger.new, Trigger.oldMap);
    }
}