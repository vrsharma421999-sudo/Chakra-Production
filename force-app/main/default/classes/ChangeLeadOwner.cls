public class ChangeLeadOwner {
    @AuraEnabled
    public static Id changeOwner(String recordId){
        List<Lead> ldlst = new List<Lead>();
        ldlst=[select id,ownerId from lead where id =: recordId];
        if(ldlst.size()>0){
            ChangeLeadOwner__c var = ChangeLeadOwner__c.getInstance();
            ldlst[0].ownerId = '005Uz000002FhTJ';//var.OwnerId__c;
            ldlst[0].Status = 'Transferred to Conversion Team';
            update ldlst;
        }
        return ldlst[0].id;
    }
}