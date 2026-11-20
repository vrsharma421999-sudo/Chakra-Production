public class AccountTriggerHandler {
    public static Integer MAXIMUM_TRIGGER_DEPTH = 16;//Warning : Never chnage this variable value
    public static Integer SHOULD_NOT_EXCEED_MAXIMUM_TRIGGER_DEPTH = 1;
    public static Boolean handlerRunMultipleTimes = false;
    
    public static void handleAcc(List<Account> listOfAccounts, Map<Id, Account> oldMap){
        if (AccountTriggerHandler.handlerRunMultipleTimes){
            return;
        }
        
        if(AccountTriggerHandler.SHOULD_NOT_EXCEED_MAXIMUM_TRIGGER_DEPTH < AccountTriggerHandler.MAXIMUM_TRIGGER_DEPTH - 1){
            System.debug('Trigger ran this many times - ' + AccountTriggerHandler.SHOULD_NOT_EXCEED_MAXIMUM_TRIGGER_DEPTH);
            AccountTriggerHandler.SHOULD_NOT_EXCEED_MAXIMUM_TRIGGER_DEPTH += 1;
        }else{
			AccountTriggerHandler.handlerRunMultipleTimes = true;
        }
        
        Set<ID> parentAccountIds = new Set<ID>();
        for(Account currentAcc: listOfAccounts){
            Account oldAcc = oldMap.get(currentAcc.Id);
            if((currentAcc.ParentId != NULL && oldAcc.ParentId != currentAcc.ParentId) 
               || oldAcc.Acc_Business_Potential__c != currentAcc.Acc_Business_Potential__c 
               || oldAcc.Child_Account_Business_Potential__c != currentAcc.Child_Account_Business_Potential__c){
                parentAccountIds.add(currentAcc.ParentId);
            }
        }
        
        if(!parentAccountIds.isEmpty()){
            Map<ID, Decimal> mapOfParentAccountIdsVsCurrency = new Map<Id, Decimal>();//to store Id with respect of currency
            List<Account> listOfAllChildAccountForThatParentId = [SELECT ID, ParentId, Acc_Business_Potential__c, Child_Account_Business_Potential__c
                                                                  FROM Account
                                                                  WHERE ParentId IN :parentAccountIds];//uss parentId se releted jitne bhi acc hai sab le aao
            System.debug('List Of All Child Account For That Parent Id - ' + listOfAllChildAccountForThatParentId);
            
            
            List<Account> listOfParentAccounts = [SELECT ID, ParentId, Child_Account_Business_Potential__c
                                                  FROM Account
                                                  WHERE Id IN :parentAccountIds];
            System.debug('List Of Parent Accounts - ' + listOfParentAccounts);
            
            if(!listOfAllChildAccountForThatParentId.isEmpty()){
                
                for(Account acc :listOfAllChildAccountForThatParentId){
                    Decimal currentSumOfChildAccountBusinessPotential = mapOfParentAccountIdsVsCurrency.get(acc.ParentId);//current stored sum value for that parent
                    
                    currentSumOfChildAccountBusinessPotential = (currentSumOfChildAccountBusinessPotential == NULL ? 0.0 : currentSumOfChildAccountBusinessPotential) 
                        										+ (acc.Acc_Business_Potential__c == NULL ? 0.0 : acc.Acc_Business_Potential__c) 
                        										+ (acc.Child_Account_Business_Potential__c == NULL ? 0.0 : acc.Child_Account_Business_Potential__c);
                    
                    mapOfParentAccountIdsVsCurrency.put(acc.ParentId, currentSumOfChildAccountBusinessPotential);
                    
                }
                
                for(Account everyParentAccount :listOfParentAccounts){
                    if(mapOfParentAccountIdsVsCurrency.containsKey(everyParentAccount.ID)){
                        everyParentAccount.Child_Account_Business_Potential__c = mapOfParentAccountIdsVsCurrency.get(everyParentAccount.ID);
                    }
                }
                if(!listOfParentAccounts.isEmpty()){
                    try{
                        System.debug('Updating Parent Accounts...');
                        update listOfParentAccounts;
                        System.debug('Parents Account Updated!!!');
                    }catch(Exception ex){
                        System.debug(ex.getMessage());
                    }
                }
            }
        }
    }
}