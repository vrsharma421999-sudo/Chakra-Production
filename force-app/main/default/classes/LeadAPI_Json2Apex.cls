public class LeadAPI_Json2Apex
{
		public Integer TOTAL_RECORDS{get;set;}
		public String MESSAGE{get;set;}
		public String STATUS{get;set;}
		public list<RESPONSE> RESPONSE{get;set;}
		public Integer CODE{get;set;}
	public class RESPONSE{
		public String SENDER_CITY{get;set;}
		public String SENDER_STATE{get;set;}
		public String SENDER_ADDRESS{get;set;}
		public String SENDER_PINCODE{get;set;}
		public String SENDER_COMPANY{get;set;}
		public String SENDER_COUNTRY_ISO{get;set;}
		public String SUBJECT{get;set;}
		public String SENDER_MOBILE_ALT{get;set;}
		public String SENDER_EMAIL{get;set;}
		public String SENDER_PHONE{get;set;}
		public String SENDER_MOBILE{get;set;}
		public String SENDER_PHONE_ALT{get;set;}
		public String SENDER_NAME{get;set;}
		public String SENDER_EMAIL_ALT{get;set;}
		//public String QUERY_TIME{get;set;}
		public String QUERY_PRODUCT_NAME{get;set;}
		//public String QUERY_TYPE{get;set;}
		public String QUERY_MESSAGE{get;set;}
		public String UNIQUE_QUERY_ID{get;set;}
		//public String QUERY_MCAT_NAME{get;set;}
		//public String RECEIVER_MOBILE{get;set;}
		//public String CALL_DURATION{get;set;}
	}
}