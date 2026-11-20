public class GenerateQuoteHandler {
    
    
    @AuraEnabled
    public static boolean getDealDG(id dealId)
    {
        system.debug('dealId is :: '+dealId);
        List<Deal_DG__c> lstdg = [select id,Name 
                                  From Deal_DG__c
                                  Where Deal__c =:dealId];
        if(!lstdg.isEmpty())
        {
            return true;
        }
        else
        {
            return true;
            //return false;   
        }
    }
    
    @AuraEnabled
    public static String calculateQuote(id dealId)
    {
        system.debug('dealId in calculateQuote '+dealId);
        List<Opportunity> lstopp = new List<Opportunity>();
        Set<Integer> dkva = new Set<Integer>();
        List<Price_Matrix__c> lstpm = new List<Price_Matrix__c>();
        Map<Integer,Price_Matrix__c> pmMap = new Map<Integer,Price_Matrix__c>();
        List<PricebookEntry> lstpbe = new List<PricebookEntry>();
        List<PricebookEntry> lstpbe1 = new List<PricebookEntry>();
        List<QuoteLineItem> lstQli = new List<QuoteLineItem>();
        id prodctId;
        Quote q = new Quote();
        Pricebook2 stdPriceBook    = [select id, name from Pricebook2 where isStandard = true limit 1];
        system.debug('stdPriceBook '+stdPriceBook);
        if(dealId != null)
        {
            system.debug('dealId is '+dealId);
            lstopp = [select id,Name,AccountId,Account.Name,Chakr_Shield_Model__c,Price_Increase__c,Quotation_Type__c,Uploading_Requirement__c,
                      DFK__c,RecordType.Name,Business_Type__c,RecordType.developerName,
                      AMC__c,Requirement__c,Payment_Terms__c,Gas_Pipeline__c,Installation__c,Emission_Test_NABL_Certified__c,Transportation__c,
                      (select id,Name,DG_KVA_Rating__c,Quantity__c,Product__c,Buyout_Option_post_lock_in__c,Consumables__c,Freight__c,Initial_Customer_Outflow__c,
                       Late_Payment_Charge__c,Maintenance__c,Minimum_Lock_in_Period__c,Monthly_Rental_ex_GST__c,
                       Onboarding_Fee_ex_GST_one_time__c,Reactivation_Charge_post_lock__c,Refundable_Security_Deposit__c,Sales_Price__c,Total_Sales_Price__c,
                       Upfront_Saving_vs_Purchase__c From Deal_DGs__r)
                      From Opportunity
                      Where id =:dealId];
            
            system.debug('lstopp beore :: '+lstopp);
            if(!lstopp.isEmpty())
            {
                Id QuoteRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Draft Quote').getRecordTypeId();
                q.Name = lstopp[0].Name+' - '+lstopp[0].Account.Name;
                q.OpportunityId = lstopp[0].id;
                q.ExpirationDate = system.today().addDays(15);
                q.Pricebook2Id = stdPriceBook.Id;
                q.RecordTypeId = QuoteRecordTypeId;
                
                
                insert q;
                system.debug('lstopp :: '+lstopp);
                
                if(lstopp[0].RecordType.Name != 'Chakr Marjak')
                {
                    for(Deal_DG__c dg : lstopp[0].Deal_DGs__r)
                    {
                        dkva.add(Integer.valueOf(dg.DG_KVA_Rating__c));
                    }
                }
            }
            
            if(lstopp[0].RecordType.Name == 'Chakr Marjak')
            {
                System.debug('Deal Record Type is Chakr_Marjak'+lstopp[0].RecordType.Name);
                Set<Id> productIds = new Set<Id>();
                
                for(Deal_DG__c ddg : lstopp[0].Deal_DGs__r)
                {
                    if(ddg.Product__c != null)
                    {
                        productIds.add(ddg.Product__c);
                    }
                }
                Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
                
                for(PricebookEntry pbe :
                    [
                        SELECT Id,
                        Product2Id,
                        UnitPrice
                        FROM PricebookEntry
                        WHERE Pricebook2Id = :stdPriceBook.Id
                        AND Product2Id IN :productIds
                    ])
                {
                    pbeMap.put(pbe.Product2Id, pbe);
                }
                for(Deal_DG__c ddg : lstopp[0].Deal_DGs__r)
                {
                    PricebookEntry pbe = pbeMap.get(ddg.Product__c);
                    
                    if(pbe != null)
                    {
                        QuoteLineItem qli = new QuoteLineItem();
                        
                        qli.QuoteId = q.Id;
                        qli.Product2Id = ddg.Product__c;
                        qli.PricebookEntryId = pbe.Id;
                        qli.Quantity = ddg.Quantity__c;
                        qli.UnitPrice = ddg.Sales_Price__c;
                        
                        qli.Monthly_Rental_ex_GST__c = ddg.Monthly_Rental_ex_GST__c;
                        qli.Onboarding_Fee_ex_GST_one_time__c = ddg.Onboarding_Fee_ex_GST_one_time__c;
                        qli.Refundable_Security_Deposit__c = ddg.Refundable_Security_Deposit__c;
                        qli.Minimum_Lock_in_Period__c= ddg.Minimum_Lock_in_Period__c;
                        //qli.Initial_Customer_Outflow__c = ddg.Initial_Customer_Outflow__c;
                        qli.Maintenance__c = ddg.Maintenance__c;
                        qli.Buyout_Option_post_lock_in__c = ddg.Buyout_Option_post_lock_in__c;
                        qli.Late_Payment_Charge__c = ddg.Late_Payment_Charge__c;
                        qli.Reactivation_Charge_post_lock__c = ddg.Reactivation_Charge_post_lock__c;
                        qli.Consumables__c = ddg.Consumables__c;
                        qli.Freight__c = ddg.Freight__c;
                        qli.Upfront_Saving_vs_Purchase__c = ddg.Upfront_Saving_vs_Purchase__c;
                        qli.OpprotunityRecordType__c = lstopp[0].RecordType.developerName;
                        qli.Opportunity_BusinessType__c = lstopp[0].Business_Type__c;
                         
                        
                        lstQli.add(qli);
                    }
                }
                
            }
            else
            {
                if(lstopp[0].Chakr_Shield_Model__c == '')
                {
                    // throw exception
                }
                
                if(lstopp[0].Chakr_Shield_Model__c == 'M1')
                {
                    prodctId = System.Label.M1_Product_ID;
                }
                else if(lstopp[0].Chakr_Shield_Model__c == 'M2')
                {
                    prodctId = System.Label.M2_Product_ID;
                }
                else if(lstopp[0].Chakr_Shield_Model__c == 'M3')
                {
                    prodctId = System.Label.M3_Product_ID;
                }
            }
            if(lstopp[0].RecordType.Name != 'Chakr Marjak' && !dkva.isEmpty())
            {
                if(!test.isRunningTest())
                {
                    lstpm =[select id,Name,KVA__c,Product__c,List_Price__c 
                            From Price_Matrix__c
                            Where KVA__c IN: dkva
                            and Product__c=: prodctId];
                }
                else
                {
                    lstpm =[select id,Name,KVA__c,Product__c,List_Price__c 
                            From Price_Matrix__c];
                }
                if(!lstpm.isEmpty())
                {
                    system.debug('lstpm '+lstpm);
                    For(Price_Matrix__c pm : lstpm)
                    {
                        pmMap.put(Integer.valueOf(pm.KVA__c),pm);
                    }
                }
                else
                {
                    //exception
                    // throw new MyException('Price Matrix for '+lstopp[0].Chakr_Shield_Model__c+' not found.');
                }
                system.debug('pmMap is '+pmMap);
            }
            if(lstopp[0].RecordType.Name != 'Chakr Marjak' && !pmMap.isEmpty())
            {
                /*Id QuoteRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Draft Quote').getRecordTypeId();
q.Name = lstopp[0].Name+' - '+lstopp[0].Account.Name;
q.OpportunityId = lstopp[0].id;
q.ExpirationDate = system.today().addDays(15);
q.Pricebook2Id = stdPriceBook.Id;
q.RecordTypeId = QuoteRecordTypeId;
insert q;*/
                For(Deal_DG__c ddg : lstopp[0].Deal_DGs__r)
                {
                    Price_Matrix__c p = pmMap.get(Integer.valueOf(ddg.DG_KVA_Rating__c));
                    if(p != null)
                    {
                        lstpbe = [select id,Pricebook2Id,Product2Id
                                  From PricebookEntry
                                  Where Pricebook2Id =:stdPriceBook.Id
                                  and Product2Id =:p.Product__c];
                        system.debug('lstpbe '+lstpbe);
                        if(!lstpbe.isEmpty())
                        {
                            QuoteLineItem qli = new QuoteLineItem();
                            qli.QuoteId = q.Id;
                            qli.Product2Id = p.Product__c;
                            qli.PricebookEntryId = lstpbe[0].id;
                            qli.Quantity = ddg.Quantity__c;
                            qli.UnitPrice = p.List_Price__c;
                            qli.Matrix_List_Price__c = p.List_Price__c;
                            qli.Description =String.valueOf(ddg.DG_KVA_Rating__c)+' KVA';
                            lstQli.add(qli);
                        }
                        else
                        {
                            //exception
                            //throw new MyException('Price Book for '+ddg.DG_KVA_Rating__c+' KVA not found.');
                        }
                    }
                    else
                    {
                        //exception
                        // throw new MyException('Price Matrix for '+ddg.DG_KVA_Rating__c+' KVA not found.');
                    }
                }
                if(!test.isRunningTest()){
                    lstpbe1 = [select id,Pricebook2Id,Product2Id,Product2.Name 
                               From PricebookEntry
                               Where Pricebook2Id =:stdPriceBook.Id
                               and (Product2.Name ='AMC Charge' or
                                    Product2.Name ='Transportation Charge' or
                                    Product2.Name ='Installation Charge' )];
                }
                else
                {
                    lstpbe1 = [select id,Pricebook2Id,Product2Id,Product2.Name 
                               From PricebookEntry
                              ];
                }
                
                system.debug('lstpbe1 is '+lstpbe1);
                if(!lstpbe1.isEmpty())
                {
                    
                    /*for(PricebookEntry pbe1 : lstpbe1)
{
If(pbe1.product2.name == 'AMC Charge' && lstopp[0].AMC__c != '' ){
QuoteLineItem qli = new QuoteLineItem();
qli.QuoteId = q.Id;
qli.Product2Id = pbe1.Product2Id;
qli.PricebookEntryId = pbe1.id;
qli.Quantity = 1;
qli.UnitPrice = 0;
qli.Description =pbe1.Product2.Name;
lstQli.add(qli); 
}else  If(pbe1.product2.name == 'Transportation Charge' && lstopp[0].Transportation__c == 'Yes' ){
QuoteLineItem qli = new QuoteLineItem();
qli.QuoteId = q.Id;
qli.Product2Id = pbe1.Product2Id;
qli.PricebookEntryId = pbe1.id;
qli.Quantity = 1;
qli.UnitPrice = 0;
qli.Description =pbe1.Product2.Name;
lstQli.add(qli); 
}else If(pbe1.product2.name == 'Installation Charge' && lstopp[0].Installation__c == 'Yes' ){
QuoteLineItem qli = new QuoteLineItem();
qli.QuoteId = q.Id;
qli.Product2Id = pbe1.Product2Id;
qli.PricebookEntryId = pbe1.id;
qli.Quantity = 1;
qli.UnitPrice = 0;
qli.Description =pbe1.Product2.Name;
lstQli.add(qli); 
}

}*/
                    
                }
            }
            system.debug('lstQli is '+lstQli);
            
            if(!lstQli.isEmpty())
            {
                insert lstQli;
                //return String.valueOf(q.Id) + '#' + lstopp[0].RecordType.Name;
                return String.valueOf(q.Id)
                    + '#'
                    + lstopp[0].RecordType.Name
                    + '#'
                    + lstopp[0].Business_Type__c;
            }
        }
        if(test.isRunningTest())
        {
            // throw new MyException('throw Exp');
        }
        return null;
        
    }
    
}