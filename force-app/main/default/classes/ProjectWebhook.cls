/**************************************************************************************************************
* @TriggerName		: ProjectTrigger(Outbound webservice)
* @Author			: Nikki Pandey
* @CreatedDate		: 30-07-2025
* @LastModifiedDate	: 
* @Description		: Whenever an Project record is inserted then we will hit the endpointurl.
* 					: (or it's field value send to the endpointurl.) 
****************************************************************************************************************/

public class ProjectWebhook {
    @future(callout = true)
    public static void sendJson(Id RecordId){
        JSONGenerator gen = System.JSON.createGenerator(true);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        ProjectEndpointurl__c var = ProjectEndpointurl__c.getInstance();
        String endpointurl = var.Endpointurl__c;
        System.debug('endpointurl is ' + endpointurl);
        //String API_ENDPOINT = 'https://openapi.hrone.cloud/api/external/project/Create';
        String API_KEY = '6fcd41341fd4115e6ba2098df9762ecbb2417720adfa38968f08e5fec20a54b4';
        String DOMAIN_CODE = 'chakr';
        if(!test.isRunningTest())
            req.setEndPoint(endpointurl);
        req.setMethod('POST');
        req.setHeader('API-Key', API_KEY);            
        req.setHeader('domaincode', DOMAIN_CODE);            
        req.setHeader('Content-Type', 'application/json');
        req.setTimeOut(12000);
        
        List<Project__c> lstpro = [Select id,Name,RECD_Sr_No__c,OwnerId 
                                   from Project__c 
                                   where Id =: RecordId];
        
        if(!lstpro.isEmpty()){
            for(Project__c pro : lstpro){
                User user = [Select Id, HROne_Employee_ID__c From User where Id =: pro.OwnerId];
                system.debug('User > '+ user);
                
                gen.writeStartObject();
                gen.writeNumberField('projectId', 0);
                if(pro.RECD_Sr_No__c != null){
                    gen.writeStringField('projectCode',pro.RECD_Sr_No__c);
                }
                if(pro.Name != null && pro.RECD_Sr_No__c != null){
                    gen.writeStringField('projectName',pro.RECD_Sr_No__c+' - '+pro.Name);
                }
                gen.writeNumberField('customerId', 2);
                if(user.HROne_Employee_ID__c != null){
                    gen.writeStringField('projectOwner', user.HROne_Employee_ID__c);
                }
                gen.writenumberField('currencyId', 32);
                gen.writeStringField('companyCode', '8');
                gen.writeEndObject();
            }
        }
        
        String jsonBody = gen.getAsString();
        System.debug('jsonBody is ' + jsonBody);
        
        if(!test.isRunningTest()){
            req.setBody(jsonBody);
            res = http.send(req);
        }else{
            res.setBody('{"projectId":0,"projectCode":"5783","projectName":"5334 Nikki Pandey_Kolkatta_2_PR","customerId":2,"currencyId":32,"companyCode":"8"}');
        }
        system.debug('response status code '+res.getStatusCode());
        system.debug('response body is '+res.getBody());
    }
}