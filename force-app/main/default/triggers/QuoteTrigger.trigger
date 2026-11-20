/*@AUTHOR 		 : Nikki Pandey
* @DESCRIPTION	 : Insert terms and condition before record save.
* @Method		 : addTermsAndConditions();
* @CREATEDATE    : 04-Feb-2025
* @MODIFIEDDATE  :
*/

Trigger QuoteTrigger on Quote (before insert,after insert,after update,before update)
{
    /*
    if(Trigger.isAfter && Trigger.isInsert)
    {
    QuoteTrgClass.sendMailAfterInsert(Trigger.new);
    }
    */
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        QuoteTrgClass.updateorInsertTotalPrice(Trigger.new, Trigger.oldmap);
    }
    if(Trigger.isBefore && Trigger.isInsert){
        QuoteTrgClass.populateSupplierDetails(Trigger.new, null);
        QuoteTrgClass.addTermsAndConditions(Trigger.new);
        QuoteTrgClass.addGeneralScopeofwork(Trigger.new);
        QuoteTrgClass.uncheckOldQuote(Trigger.new);
    }
    //populate supplier details -added by Vanshika (02/09/2026)
     if(Trigger.isBefore && Trigger.isUpdate){
        QuoteTrgClass.populateSupplierDetails(Trigger.new, Trigger.oldMap);
    }
}