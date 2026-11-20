/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : QuoteAssetController
 * Author          : Shubhanshu Mohan
 * Created Date    : Feb 8, 2026
 * Description     :
 * Fetch Assets related to Quote's Opportunity and
 * create Quote Line Items for selected rows only.
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
public with sharing class QuoteAssetController {

    public class AssetQuoteWrapper {
        @AuraEnabled public Id assetId { get; set; }
        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public String service { get; set; }
        @AuraEnabled public String serviceYear { get; set; }
        @AuraEnabled public Decimal price { get; set; }
        @AuraEnabled public Decimal discount { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
    }

    /* =========================
       Fetch Service Year Options
       ========================= */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getServiceYearOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        try {
            // Dynamic check to ensure field exists before accessing
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.QuoteLineItem.fields.getMap();
            if (fieldMap.containsKey('Service_Year__c')) {
                Schema.DescribeFieldResult fieldResult = fieldMap.get('Service_Year__c').getDescribe();
                for (Schema.PicklistEntry ple : fieldResult.getPicklistValues()) {
                    if (ple.isActive()) {
                        options.add(new Map<String, String>{
                            'label' => ple.getLabel(),
                            'value' => ple.getValue()
                        });
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error fetching picklist values: ' + e.getMessage());
        }
        return options;
    }

    /* =========================
       Fetch Assets for Quote
       ========================= */
    @AuraEnabled(cacheable=true)
    public static List<AssetQuoteWrapper> getAssets(Id quoteId) {

        List<AssetQuoteWrapper> result = new List<AssetQuoteWrapper>();
        if (quoteId == null) return result;

        Quote q = [
            SELECT Id, OpportunityId, Opportunity.Service__c
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];

        System.debug('getAssets called with quoteId: ' + quoteId);
        if (q.OpportunityId == null) {
            System.debug('OpportunityId is null for quote: ' + quoteId);
            return result;
        }

        // Fetch existing Quote Line Items for this Quote
        Map<Id, QuoteLineItem> productToQLIMap = new Map<Id, QuoteLineItem>();
        
        //  Dynamic logic for Service_Year__c
        String qliQuery = 'SELECT Id, Product2Id, Quantity, UnitPrice,Discount FROM QuoteLineItem WHERE QuoteId = :quoteId';
        Boolean hasServiceYear = false;
        try {
            if (Schema.SObjectType.QuoteLineItem.fields.getMap().containsKey('Service_Year__c')) {
                qliQuery = 'SELECT Id, Product2Id, Quantity, UnitPrice, Service_Year__c,Discount FROM QuoteLineItem WHERE QuoteId = :quoteId';
                hasServiceYear = true;
            }
        } catch(Exception e) { System.debug('Field Check Exception: ' + e.getMessage()); }

        for (QuoteLineItem qli : Database.query(qliQuery)) {
            productToQLIMap.put(qli.Product2Id, qli);
        }

        List<Asset__c> assets = [
            SELECT Id, Product__c, Product__r.Name, RECD_Serial_No__c
            FROM Asset__c
            WHERE Deal__c = :q.OpportunityId
        ];

        for (Asset__c a : assets) {
            AssetQuoteWrapper w = new AssetQuoteWrapper();
            w.assetId     = a.Id;
            w.productId   = a.Product__c;
            w.productName = a.Product__r != null ? a.Product__r.Name : 'Product Not Selected in Asset';
            w.service     = a.RECD_Serial_No__c; // RECD Serial Number

            
            if (a.Product__c != null && productToQLIMap.containsKey(a.Product__c)) {
                QuoteLineItem existingQLI = productToQLIMap.get(a.Product__c);
                w.quantity = existingQLI.Quantity;
                w.price    = existingQLI.UnitPrice;
                w.discount = existingQLI.Discount;
                w.selected = true;
                if (hasServiceYear) {
                    w.serviceYear = (String)existingQLI.get('Service_Year__c');
                }
            } else {
                w.quantity = 1;
                w.price    = 0;
                w.discount = 0;
                w.selected = false;
            }
            result.add(w);
        }
        return result;
    }

    /* =========================
       Save Selected Rows (Sync Logic)
       ========================= */
    @AuraEnabled
    public static void saveQuoteLines(Id quoteId, List<AssetQuoteWrapper> rows) {
        if (quoteId == null || rows == null || rows.isEmpty()) return;

        Quote q = [SELECT Id, Pricebook2Id FROM Quote WHERE Id = :quoteId LIMIT 1];

Pricebook2 standardPb = [
    SELECT Id 
    FROM Pricebook2 
    WHERE IsStandard = true 
    LIMIT 1
];

if (q.Pricebook2Id == null || q.Pricebook2Id != standardPb.Id) {
    q.Pricebook2Id = standardPb.Id;
    update q;
}
        
        Set<Id> assetsToMark = new Set<Id>();



        Map<Id, QuoteLineItem> productToQLIMap = new Map<Id, QuoteLineItem>();
        for (QuoteLineItem qli : [SELECT Id, Product2Id FROM QuoteLineItem WHERE QuoteId = :quoteId]) {
            productToQLIMap.put(qli.Product2Id, qli);
        }

        Set<Id> selectedProductIds = new Set<Id>();
        for (AssetQuoteWrapper row : rows) {
            if (row != null && row.selected == true && row.productId != null) {
                selectedProductIds.add(row.productId);
            }
        }

        Map<Id, PricebookEntry> productToPbeMap = new Map<Id, PricebookEntry>();
        if (!selectedProductIds.isEmpty()) {
            for (PricebookEntry pbe : [
                SELECT Id, Product2Id, UnitPrice, Product2.Item_Id__c
                FROM PricebookEntry
                WHERE Product2Id IN :selectedProductIds
                  AND Pricebook2Id = :q.Pricebook2Id
                  AND IsActive = true
            ]) {
                productToPbeMap.put(pbe.Product2Id, pbe);
            }
        }

        Boolean hasServiceYear = Schema.SObjectType.QuoteLineItem.fields.getMap().containsKey('Service_Year__c');

        List<QuoteLineItem> toUpsert = new List<QuoteLineItem>();
        List<Id> toDeleteIds = new List<Id>();

        for (AssetQuoteWrapper row : rows) {
            if (row == null || row.productId == null) continue;
            QuoteLineItem existingQLI = productToQLIMap.get(row.productId);

            if (row.selected == true) {
                PricebookEntry pbe = productToPbeMap.get(row.productId);
                if (pbe == null) throw new AuraHandledException('Product "' + row.productName + '" is not active.');
                

                QuoteLineItem qli = new QuoteLineItem();
                if (existingQLI != null) {
                    qli.Id = existingQLI.Id;
                } else {
                    qli.QuoteId = quoteId;
                    qli.PricebookEntryId = pbe.Id;
                }
                
                qli.Quantity = 1; //  Enforced 1
                qli.UnitPrice = row.price != null ? row.price : 0;
                qli.Asset__c=row.assetId;
                qli.RECD_Serial_No__c=row.service;
                qli.Discount=row.discount;
                
                if (row.assetId != null) {
    assetsToMark.add(row.assetId);
}

                
                if (hasServiceYear) {
                    qli.put('Service_Year__c', row.serviceYear);
                }
                
                qli.Matrix_List_Price__c = pbe.UnitPrice;
                if (pbe.Product2 != null) qli.Item_Id__c = pbe.Product2.Item_Id__c;

                toUpsert.add(qli);
            } else {
                if (existingQLI != null) toDeleteIds.add(existingQLI.Id);
            }
        }

        if (!toDeleteIds.isEmpty()) delete [SELECT Id FROM QuoteLineItem WHERE Id IN :toDeleteIds];
        if (!toUpsert.isEmpty()){
            upsert toUpsert;
             System.debug('After Upsert QLI: ' + [SELECT Id, RECD_Serial_No__c FROM QuoteLineItem WHERE Id IN :toUpsert]);
        } 
        
        if (!assetsToMark.isEmpty()) {
    List<Asset__c> assetsToUpdate = new List<Asset__c>();

    for (Id assetId : assetsToMark) {
        assetsToUpdate.add(new Asset__c(
            Id = assetId,
            Quote_Exists__c = true
        ));
    }

    update assetsToUpdate;
}

    }
}