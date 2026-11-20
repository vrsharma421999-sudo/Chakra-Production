public class LeadAPI 
{
	 @future(callout=true)
	public static void AuthorizationMtd(String entity)
      {
        String endPointURL;
        List<Lead> lstlid = new List<Lead>();
        List<String> sessionDetails=new List<String>();
         
        endPointURL = 'https://mapi.indiamart.com/wservce/crm/crmListing/v2/?glusr_crm_key=mR27Fblt5XjFT/et4XyD7luJqlXCnTdh';  
        
        HttpRequest req = new HttpRequest();  
        req.setMethod('GET');
        req.setEndpoint(endPointURL);
        req.setTimeout(120000); 

        Http http = new Http();
          HTTPResponse res=new HTTPResponse();
          if(!Test.isRunningTest())
          {
              res = http.send(req);
          }else{ 
              res=new HTTPResponse();
              res.setStatusCode(200); 
              string dummy = '';
              
              res.setBody('{"CODE": 200,"STATUS": "SUCCESS","MESSAGE": "","TOTAL_RECORDS": 21,"RESPONSE": [{"UNIQUE_QUERY_ID": "2327707338","QUERY_TYPE": "W","QUERY_TIME": "2022-12-29 13:51:49","SENDER_NAME": "Arzoo Patel","SENDER_MOBILE": "+91-9825953273","SENDER_EMAIL": "","SUBJECT": "Requirement for 15 Kg Oil","SENDER_COMPANY": "test company","SENDER_ADDRESS": "Anand, Gujarat","SENDER_CITY": "Anand","SENDER_STATE": "Gujarat","SENDER_COUNTRY_ISO": "IN","SENDER_MOBILE_ALT": "","SENDER_PHONE": "","SENDER_PHONE_ALT": "","SENDER_EMAIL_ALT": "","QUERY_PRODUCT_NAME": "15 Kg Oil","QUERY_MESSAGE": "I want to purchase 15 Kg Oil. Kindly send me price and other details.<br> Quantity :   10<br> Quantity Unit :   Piece<br> Probable Order Value :   Rs. 3,000 to 10,000<br> Why do you need this :   For Business Use<br>","CALL_DURATION": "","RECEIVER_MOBILE": ""}]}');
          }
          if(res.getStatusCode() == 200)
          {
              System.debug('Response body is' + res.getBody());
              LeadAPI_Json2Apex resdata = (LeadAPI_Json2Apex) System.JSON.deserialize(res.getBody(), LeadAPI_Json2Apex.class);
			  System.debug('resdata is  '+ resdata);
              if(resdata.RESPONSE.size()>0)
              {
                  for(LeadAPI_Json2Apex.RESPONSE singleres: resdata.RESPONSE)
                  {
                      System.debug('Name is ' + singleres.SENDER_NAME);
                      System.debug('Message is ' + singleres.QUERY_MESSAGE);
                      
                      Lead l = new Lead();
                      l.External_Id__c = singleres.UNIQUE_QUERY_ID;
                      l.LastName = singleres.SENDER_NAME;
                      l.MobilePhone = singleres.SENDER_MOBILE;
                      l.Email = singleres.SENDER_EMAIL;
                      l.Alt_Email__c = singleres.SENDER_EMAIL_ALT; 
                      if(singleres.SENDER_COMPANY != ''){
                          l.Company = singleres.SENDER_COMPANY;
                      }else{
                          l.Company = 'Not Available';
                      }
                      
                      l.Street = singleres.SENDER_ADDRESS; 
                      l.City = singleres.SENDER_CITY;
                      l.State = singleres.SENDER_STATE;
                      l.PostalCode = singleres.SENDER_PINCODE;
                      l.Country = singleres.SENDER_COUNTRY_ISO;
                      l.Alt_Mobile__c = singleres.SENDER_MOBILE_ALT;
                      l.Phone = singleres.SENDER_PHONE;
                      l.Alt_Phone__c = singleres.SENDER_PHONE_ALT;
                      l.Products_offered__c = singleres.QUERY_PRODUCT_NAME;
                      l.Description = singleres.SUBJECT;
                      l.Customer_Enquiry__c = singleres.QUERY_MESSAGE;
                      l.Channel__c = 'Marketing';
                      l.Source__c = 'Indiamart';
                      l.Sub_Source__c = 'Direct';
                          
                      lstlid.add(l);
                     
                  }
                  System.debug('Last insert in lstlid ' + lstlid);
                  upsert lstlid External_Id__c;
              }
          }   
      }
}