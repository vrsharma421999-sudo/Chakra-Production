public class SalesQuoteController {
    
    id qid;
    public List<QuoteLineItem> lstline{get; set;}
    public List<Quote> lstQuote{get; set;}
    public List<salesQuoteWrapper> lstwrap{get; set;}
    Public Decimal TotalAmount1 {get;set;}
    Public String AmountInWord {get;set;}
    public integer s  = 0;
    public Integer noOfItem{get; set;}
    public Date Today { get { return Date.today(); }}
    Public String tnC {get;set;}
	Public String sow {get;set;}
    public List<String> sowLines {get; set;}
    public List<String> tnCLines {get; set;}
    
    public SalesQuoteController(ApexPages.StandardController controller) {
        qid=ApexPages.currentPage().getParameters().get('id');
        system.debug('qid is  '+qid);
        lstline = [select id,Product2.Name,Product2.HSN_SAC_Code__c,TotalPrice,Subtotal,Asset__r.KVA_Rating__c,
                   Discount,Product2.Item_Id__c,Item_Id__c,Quantity,Unit__c,UnitPrice,
                   GST_Rate__c,GST_Amount__c,GST_Amount_1__c,DG_Make__c,ListPrice,RECD_Serial_No__c,Total_Initial_Commercials_Cost_In_GST__c
                   From QuoteLineItem  
                   where QuoteId =:qid];
        system.debug('lstline is '+lstline);
        noOfItem =0;
        TotalAmount1 = 0.0;
        AmountInWord = '';
        noOfItem = lstline.size();
        lstwrap=new List<salesQuoteWrapper>();
        For(QuoteLineItem ql : lstline)
        {
            salesQuoteWrapper sqw = new salesQuoteWrapper();
            if(ql.TotalPrice != null)
            {
                sqw.TaxableAmount = ql.TotalPrice;
                sqw.TaxableAmount = sqw.TaxableAmount.setScale(2);
            }
            if(ql.GST_Amount_1__c != null)
            {
                sqw.TotalAmount = sqw.TaxableAmount + ql.GST_Amount_1__c;
                sqw.TotalAmount = sqw.TotalAmount.setScale(2);
            }
            if(ql.UnitPrice != null && ql.Discount != null){
                sqw.discountOnUnitPrice = (ql.UnitPrice * ql.Discount/100);
                sqw.discountOnUnitPrice1 = ql.UnitPrice - sqw.discountOnUnitPrice;
            }
            if(ql.UnitPrice != null && ql.Discount == null){
                ql.Discount = 0;
                sqw.discountOnUnitPrice = (ql.UnitPrice * ql.Discount/100);
                sqw.discountOnUnitPrice1 = ql.UnitPrice - sqw.discountOnUnitPrice;
            }
            System.debug('discountOnUnitPrice is ' + sqw.discountOnUnitPrice);
            s =s+1;
            sqw.sno = s;
            sqw.qline = ql;
            lstwrap.add(sqw);
        }
        lstQuote = [SELECT Id,Name,subtotal,Terms_And_Conditions__c,Quotation_Type__c,General_Scope_of_Work__c,Total_Amount__c FROM Quote WHERE Id =: qid];
        for(Quote qObj : lstQuote)
        {
             if(qObj.Quotation_Type__c == 'Editable')
    {
        tnC = qObj.Terms_And_Conditions__c;
        sow = qObj.General_Scope_of_Work__c;
    }
    else
    {
        //  Your default / hardcoded values
        tnC = 'Default Terms & Conditions goes here';
        sow = 'Default Scope of Work goes here';
    }
            TotalAmount1 = qObj.Total_Amount__c;
        }
        if(sow != null){
            sow = sow.replaceAll('(?i)<br[^>]*>', '\n');
            sow = sow.replaceAll('(?i)</p>', '\n');
            sow = sow.stripHtmlTags();
            sow = sow.unescapeHtml4();
            sow = sow.replaceAll('\\s+(?=(\\*\\*)?\\d+(\\)|\\.)(\\.)?[\\s])', '\n');
            sow = sow.replaceAll('\\s+(?=(\\*\\*)?[a-zA-Z](\\)|\\.)(\\.)?[\\s])', '\n');
            sow = sow.replaceAll('\\r\\n|\\r', '\n');
            sow = sow.replaceAll('\\n{2,}', '\n');

            List<String> lines = sow.split('\n');
            sowLines = new List<String>();
            for(String line : lines){
                line = line.trim();
                if(String.isBlank(line)) continue;
                if(Pattern.matches('^(\\*\\*)?\\d+(\\)|\\.)(\\.)?.*', line)){
                    // Main numbered point (starts flush)
                } else if(Pattern.matches('^(\\*\\*)?[a-zA-Z](\\)|\\.)(\\.)?.*', line)){
                    // Sub-clause (indent)
                    line = '&nbsp;&nbsp;&nbsp;&nbsp;' + line;
                } else {
                    line = '&nbsp;&nbsp;&nbsp;&nbsp;' + line;
                }
                /*
                * Added by: Vanshika
                * Date: 12-10-2026
                * Reason: Convert markdown **text** into bold <b>text</b> for Scope of Work
                */
                line = line.replaceAll('\\*\\*(.*?)\\*\\*', '<b>$1</b>');
                sowLines.add(line);
            }
        }
        if(tnC != null){
            tnC = tnC.replaceAll('(?i)<br[^>]*>', '\n');
            tnC = tnC.replaceAll('(?i)</p>', '\n');
            tnC = tnC.stripHtmlTags();
            tnC = tnC.unescapeHtml4();
            tnC = tnC.replaceAll('\\s+(?=(\\*\\*)?\\d+(\\)|\\.)(\\.)?[\\s])', '\n');
            tnC = tnC.replaceAll('\\s+(?=(\\*\\*)?[a-zA-Z](\\)|\\.)(\\.)?[\\s])', '\n');
            tnC = tnC.replaceAll('\\r\\n|\\r', '\n');
            tnC = tnC.replaceAll('\\n{2,}', '\n');

            List<String> lines = tnC.split('\n');
            tnCLines = new List<String>();
            for(String line : lines){
                line = line.trim();
                if(String.isBlank(line)) continue;
                if(Pattern.matches('^(\\*\\*)?\\d+(\\)|\\.)(\\.)?.*', line)){
                    // Main numbered point (starts flush)
                } else if(Pattern.matches('^(\\*\\*)?[a-zA-Z](\\)|\\.)(\\.)?.*', line)){
                    // Sub-clause (indent)
                    line = '&nbsp;&nbsp;&nbsp;&nbsp;' + line;
                } else {
                    line = '&nbsp;&nbsp;&nbsp;&nbsp;' + line;
                }
                /*
                * Added by: Vanshika
                * Date: 12-10-2026
                * Reason: Convert markdown **text** into bold <b>text</b> for Terms & Conditions
                */
                line = line.replaceAll('\\*\\*(.*?)\\*\\*', '<b>$1</b>');
                tnCLines.add(line);
            }
        }
        CurrencyConvertor obj = new CurrencyConvertor();
        If(TotalAmount1 != null)
            AmountInWord = obj.Convert(TotalAmount1);
        //TotalAmount1 = 
        //  system.debug('TaxableAmount  is'+TaxableAmount);
        system.debug('lstwrap'+lstwrap);
    }
    
    public class salesQuoteWrapper
    {
        public QuoteLineItem qline{get;set;}
        public integer sno{get;set;}
        public decimal TaxableAmount {get;set;}
        public decimal TotalAmount {get;set;}
        public decimal discountOnUnitPrice {get;set;}
        public decimal discountOnUnitPrice1 {get;set;}
        
        salesQuoteWrapper()
        {
            qline = new QuoteLineItem();
            sno = 0;
            TaxableAmount = 0.0;
            TotalAmount = 0.0;
            discountOnUnitPrice = 0.0;
            discountOnUnitPrice1 = 0.0;
        }
    }
}