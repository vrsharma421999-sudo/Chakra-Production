public class CheckInServiceVisitCtrl {
 public Double valueLong { get; set; }
    public Double valueLat { get; set; }
    Public Visit_Plan__c retailer{get;set;}
    Public string recordid{get;set;}
      public CheckInServiceVisitCtrl(ApexPages.StandardController controller){
          recordid = apexpages.currentpage().getparameters().get('id');
          system.debug('record id is ' + recordid);
        retailer= [Select id,Check_in_Location__c,Check_in_Date_Time__c,Check_out_Date_Time__c,Check_out_Location__c from Visit_Plan__c where id=: recordid];
    	System.debug('<<retailer>>' +retailer);
          
      }
      public void iFoundYou() {
       if(retailer.Check_in_Location__c ==null )
       {
           system.debug('valueLat is'+valueLat);
        retailer.Check_in_Location__Latitude__s= valueLat;
        retailer.Check_in_Location__Longitude__s= valueLong;
        retailer.Check_in_Date_Time__c = system.now(); 
           system.debug('valuelat::'+valueLat);
           system.debug('valuelong::'+valueLong);
           
           
           String address1='valueLat+valueLat';
           //String address='28.500497+77.318504';
        String Key='AIzaSyD6WRBA7gxZBvG6JQjxAjVHkXFlgngP5g0';
        Http httpProtocol = new Http();
           List<String> item= new List<String>();
        HttpRequest request = new HttpRequest();
       // String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='+valueLat+','+valueLong+'&radius=2000&key=AIzaSyD6WRBA7gxZBvG6JQjxAjVHkXFlgngP5g0';
        String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='+valueLat+','+valueLong+'&radius=2000&key='+system.label.googleKry;
        System.debug(endpoint);
           request.setEndpoint(endpoint);
        request.setMethod('GET');
             HttpResponse response;
           if(!test.isRunningTest())
           {
              response = httpProtocol.send(request);
           }
           else
           {
               response = new HttpResponse();
               GoogleAPIParse gp =new GoogleAPIParse();
               gp.results = new List<GoogleAPIParse.Results>();
               GoogleAPIParse.results rprecords =new  GoogleAPIParse.results();
               rprecords.formatted_address ='test address';
               rprecords.place_id ='test id';
               rprecords.address_components  =new List<GoogleAPIParse.Address_components>();
               for(integer i=0; i<5; i++)
               {
                    GoogleAPIParse.Address_components addcomp =new  GoogleAPIParse.Address_components();
                   addcomp.long_name ='test long name';
                   addcomp.short_name='test short name';
                   rprecords.address_components.add(addcomp);
               }
           
                gp.results.add(rprecords);
               String body =JSON.serialize(gp);
               response.setBody(body);
           }
       
        System.debug('####Body : '+response.getBody());
           String rows= '';
        try{
            if(response.getBody()!=null){
                GoogleAPIParse distance= GoogleAPIParse.parse(response.getBody());
                String Name;
                String State, District, Postal, Country, taluka,addrss;
                Integer size= 0;
                

                system.debug('SIZEEEEE'+distance.results[0].address_components.size());
                size=distance.results[0].address_components.size();
                
                Postal= distance.results[0].address_components[size-1].long_name;
                Country = distance.results[0].address_components[size-2].long_name;
                State= distance.results[0].address_components[size-3].long_name;
                District= distance.results[0].address_components[size-4].long_name;
                taluka= distance.results[0].address_components[size-5].long_name;
                System.debug('<<taluka>' +taluka);
                addrss=distance.results[0].formatted_address;
                
                system.debug('Postal::'+Postal+' Country::'+Country+' State::'+State+' District::'+District+' taluka::'+taluka+'  addrss::'+addrss);
                
                String address=addrss;
                
				item = address.split('-');
                
                system.debug('item::'+item);
                retailer.Check_in_Address__c= address;

                         
                        
                }
            
        }catch(Exception e){
        
        }
        
        system.JSONParser parser = JSON.createParser(response.getBody());
        //return item;
        update retailer;
           
           
           
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'You have been successfully Check-In'));
       } else
       {
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Check-In Location Already Captured'));
       }
      }
         public void iFoundYou1() {
         System.debug('Heyy');
        if(retailer.Check_in_Location__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Check In First...!!'));  }else if(retailer.Check_Out_Location__c ==null ){retailer.Check_Out_Location__Latitude__s= valueLat; System.debug('<<retailer.Check_Out_Location__Latitude__s>>' +retailer.Check_Out_Location__Latitude__s);        retailer.Check_Out_Location__Longitude__s= valueLong;                      System.debug('<<retailer.Check_Out_Location__Longitude__s>>' +retailer.Check_Out_Location__Longitude__s);        retailer.Check_Out_Date_Time__c = system.now();
                                                                                                                                                                  System.debug('<<retailer.Check_Out_Date_Time__c>>' +retailer.Check_Out_Date_Time__c);
                                                                                                                                                                  
                                                                                                                                                                  String address1='valueLat+valueLat';
           //String address='28.500497+77.318504';
        String Key='AIzaSyD6WRBA7gxZBvG6JQjxAjVHkXFlgngP5g0';
       Http httpProtocol = new Http();
        List<String> item= new List<String>();
        HttpRequest request = new HttpRequest();
       String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='+valueLat+','+valueLong+'&radius=2000&key='+system.label.googleKry;
       request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = httpProtocol.send(request);
        System.debug('####Body : '+response.getBody());
                                                                                                                                                                  
           String rows= '';
        try{            if(response.getBody()!=null){                GoogleAPIParse distance= GoogleAPIParse.parse(response.getBody());                String Name;                String State, District, Postal, Country, taluka,addrss;                Integer size= 0;
                

                system.debug('SIZEEEEE'+distance.results[0].address_components.size());
                size=distance.results[0].address_components.size();               Postal= distance.results[0].address_components[size-1].long_name;                Country = distance.results[0].address_components[size-2].long_name;                State= distance.results[0].address_components[size-3].long_name;                District= distance.results[0].address_components[size-4].long_name;                taluka= distance.results[0].address_components[size-5].long_name;                System.debug('<<taluka>' +taluka);                addrss=distance.results[0].formatted_address;
                
                system.debug('Postal::'+Postal+' Country::'+Country+' State::'+State+' District::'+District+' taluka::'+taluka+'  addrss::'+addrss);
                
                String address=addrss;			item = address.split('-');                          system.debug('item::'+item);                retailer.Check_Out_Address__c= address;            
                }        }catch(Exception e){                }                system.JSONParser parser = JSON.createParser(response.getBody());                                                                                                                                                                                                                                                                                                                                            update retailer;           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'You have been successfully Check-Out'));       }else{ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Check-Out Location Already Captured'));
        } 
    } 
}