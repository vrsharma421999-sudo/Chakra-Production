public class SalesQuotationAuraController
{    
    @AuraEnabled
    public static String createQuoteDocument(id qid, Boolean isMobile)
    {
        system.debug('Quote Id : ' + qid);
        List<Quote> qList = new List<Quote>();
        Set<Id> oppId = new Set<Id>();
        User userInfo = new User();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Id> docId = new List<id>();
        
        qList = [Select id, Name, Owner.Email, OpportunityId,Q_1__c,Q_N__c
                 from Quote where Id =: qid];
        system.debug('Quote List : ' + qList);
        if(!qList.isEmpty())
        {
            for(Quote q1 : qList)
            {
                oppId.add(q1.OpportunityId);
            }
        }
        System.debug('Opportunity id is not null ' + oppId);
        if(!oppId.isEmpty())
        {
            oppList = [Select Id, Name, StageName, OwnerId, RecordType.Name From Opportunity Where Id =: oppId];
            System.debug('Opportunity List is : ' + oppList);
            for(Opportunity opp : oppList)
            {
                System.debug('inside for loop of Opportunity');
                userInfo = [Select Id, Email, ManagerEmail__c From User Where Id =: opp.OwnerId];
            } 
        }
        
        //VisualforcePageName should be replaced by your org vf page that rendered as PDF
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        Quote q = [Select id, Owner.Email, Name, Q_1__c,Q_N__c,Rental_Budgetary_Quotation__c, Opportunity.RecordType.Name,Opportunity.Business_Type__c from Quote where Id =: qid LIMIT 1];
        String recordTypeName = q.Opportunity.RecordType.Name;
        PageReference pref;
        /*if(recordTypeName == 'AMC') {
            pref = page.ServiceQuotation;
        } else {
            pref = page.SalesQuotation;
        }*/
        
        String businessType = q.Opportunity.Business_Type__c;
        
        if(recordTypeName == 'AMC')
        {
            pref = Page.ServiceQuotation;
        }
        else if(recordTypeName == 'Chakr Marjak' &&
                businessType == 'Sales')
        {
            pref = Page.SalesPdfChakrMarjak;
        }
        else if(recordTypeName == 'Chakr Marjak' &&
                businessType == 'Rental')
        {
            if(q.Rental_Budgetary_Quotation__c)
            {
                pref = Page.RentalBudgetaryPdf;
            }
            else
            {
                pref = Page.ChakrMarjakRentalProposal;
            }
        }
        else
        {
            pref = Page.SalesQuotation;
        }
        
        pref.getParameters().put('Id',qid);//Replace with quote Id
        pref.setRedirect(true);
        Blob bdata = null;
        if(!Test.isRunningTest())
            bdata = pref.getContentAsPDF() ;   
        List<QuoteDocument> lstquotedoc = new List<QuoteDocument>(); 
        QuoteDocument quotedoc = new QuoteDocument(); 
        quotedoc.Document = bdata;                
        quotedoc.QuoteId = qid; //Replace with quote Id
        lstquotedoc.add(quotedoc);
        System.debug('lstquotedoc is ' + lstquotedoc.size());
        if(!lstquotedoc.isEmpty() && !test.isRunningTest())
            insert lstquotedoc; 
        
        List<QuoteDocument> quoteDocs = [SELECT Id FROM QuoteDocument WHERE QuoteId = :qid];
        List<Quote> updQuote = new List<Quote>();
        for(Quote qs : qList){
            Integer pdfCount = quoteDocs.size();
            system.debug('pdfCount is' + pdfCount);
            if(pdfCount>1){
                qs.Q_N__c=TRUE;
                qs.Q_1__c=FALSE;
            }
            else if(pdfCount==1){
                qs.Q_1__c=TRUE;
                qs.Q_N__c=FALSE;
            }
            updQuote.add(qs);
        }
        if(!updQuote.isEmpty()){
            update updQuote;
        }
        
        Attachment dcdoc = new Attachment(); 
        dcdoc.ParentId = qid;
        dcdoc.Body = bdata;
        dcdoc.Name = 'Quote.pdf';
        If(!test.isRunningTest())
            Insert dcdoc;
        
        docId.add(dcdoc.Id);
        If(!docId.isEmpty())
        {
            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            emailMsg.setToAddresses(new String[] {userInfo.Email});
            emailMsg.setCcAddresses(new String[] {userInfo.ManagerEmail__c});
            emailMsg.setSubject('Quotation : '+q.Name+' is generated for '+ oppList[0].Name +'.');
            string contentBody = 'Quotation '+q.Name+' is generated for ('+ oppList[0].Name +')'+'\n\n'+
                             'Your Quote pdf form is created successfully here is the copy of your pdf';
            emailMsg.setPlainTextBody(contentBody);
            emailMsg.setEntityAttachments(docId);
            emailList.add(emailMsg);
        }
        try 
        {
            if(!emailList.isEmpty())
            {
                Messaging.sendEmail(emailList);
            }
        } 
        catch(Exception e) 
        {
            System.debug(e);
        }
        
       // return recordTypeName;
       return recordTypeName + '#'+ q.Opportunity.Business_Type__c + '#'+ String.valueOf(q.Rental_Budgetary_Quotation__c);
    }
}