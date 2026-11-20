public class CheckOutApexController {
    @AuraEnabled
    public static String checkout(Decimal lat, Decimal lon,Id cid, String Outcome){
        Id  userId=UserInfo.getUserId();
        System.debug(lat+' Lat - Lon '+lon);
        System.debug('id:::::'+cid+' CheckOutOwnerId '+userId);
        List<Visit_Plan__c> checkout = new List<Visit_Plan__c>();
        checkout = [Select id, Check_in_Location__c, Check_out_Location__c from Visit_Plan__c where Id = :cId];
        System.debug('checkout ::::'+checkout.size());
        
        if(checkout[0].Check_in_Location__c == null)
        {
            throw new System.StringException('Please Check In First...!!');
        }
        else if(checkout[0].Check_out_Location__c == null)
        {
            Visit_Plan__c visitPlan = new Visit_Plan__c();
            visitPlan.Check_Out_Location__Longitude__s = lon;
            visitPlan.Check_Out_Location__Latitude__s = lat;
            visitPlan.Check_out_Date_Time__c = System.now();
            visitPlan.id = cid;
            visitPlan.Outcome__c = Outcome;
            
            String address1 = 'lat+lat';
            //String address ='28.500497+77.318504';
            //String Key = 'AIzaSyD6WRBA7gxZBvG6JQjxAjVHkXFlgngP5g0';
            Http httpProtocol = new Http();
            List<String> item = new List<String>();
            HttpRequest request = new HttpRequest();
            String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='+lat+','+lon+'&radius=2000&key='+system.label.googleKry+'&region=IN';
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            HttpResponse response = new HttpResponse();
            if(!Test.isRunningtest())
            {
                response = httpProtocol.send(request);
                System.debug('Response Body >> '+response.getBody());
            }
            else
            {
                response = httpProtocol.send(request);
                response.setBody('{"plus_code":{"compound_code":"F2Q2+JM5 Gurugram, Haryana, India","global_code":"7JWVF2Q2+JM5"},"results":[{"address_components":[{"long_name":"A-10","short_name":"A-10","types":["premise"]},{"long_name":"Shankar Vihar","short_name":"Shankar Vihar","types":["political","sublocality","sublocality_level_2"]},{"long_name":"Sector 104","short_name":"Sector 104","types":["political","sublocality","sublocality_level_1"]},{"long_name":"Gurugram","short_name":"Gurugram","types":["locality","political"]},{"long_name":"Gurugram","short_name":"Gurugram","types":["administrative_area_level_3","political"]},{"long_name":"Gurgaon Division","short_name":"Gurgaon Division","types":["administrative_area_level_2","political"]},{"long_name":"Haryana","short_name":"HR","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]},{"long_name":"122006","short_name":"122006","types":["postal_code"]}],"formatted_address":"A-10, Shankar Vihar, Sector 104, Gurugram, Haryana 122006, India","geometry":{"location":{"lat":28.488942,"lng":77.00152199999999},"location_type":"ROOFTOP","viewport":{"northeast":{"lat":28.4902909802915,"lng":77.0028709802915},"southwest":{"lat":28.48759301970849,"lng":77.00017301970848}}},"navigation_points":[{"location":{"latitude":28.4889068,"longitude":77.0015308}}],"place_id":"ChIJx9WPdl0XDTkRB3A3b_geMOc"}]}');
            }
            //String rows= '';
            Try{
                if(response.getBody() != null){
                    GoogleAPIParse distance = GoogleAPIParse.parse(response.getBody());
                    String Name;
                    String State, District, Postal, Country, taluka,addrss; 
                    /*Integer size = 0;
                    
                    system.debug('SIZEEEEE'+distance.results[0].address_components.size());
                    size = distance.results[0].address_components.size();
                    Postal = distance.results[0].address_components[size-1].long_name;
                    Country = distance.results[0].address_components[size-2].long_name;
                    State = distance.results[0].address_components[size-3].long_name;
                    District = distance.results[0].address_components[size-4].long_name;
                    taluka = distance.results[0].address_components[size-5].long_name;
                    System.debug('<<taluka>' +taluka);*/
                    if(distance.results[0] != null){
                        addrss = distance.results[0].formatted_address;
                    }
                    
                    /*system.debug('Postal >> '+Postal+' Country >> '+Country+' State >> '+State+' District >> '+District+' taluka >> '+taluka+'  addrss >> '+addrss);
                    String address = addrss;			
                    item = address.split('-');                         
                    system.debug('item::'+item);*/
                    visitPlan.Check_Out_Address__c = addrss;            
                }        
                update visitPlan;
            }
            catch(Exception e){
                if(!Test.isRunningTest()){
                    System.debug('error message::::'+e.getMessage());
                    //throw new System.StringException(e.getMessage());
                }
            }
        }
        else  {
            throw new System.StringException('Check-Out Location Already Captured');
        }
        return 'Success';
    } 
}