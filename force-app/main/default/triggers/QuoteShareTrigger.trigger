trigger QuoteShareTrigger on Quote (after insert) 
{
    if(Trigger.isAfter && Trigger.isInsert){
        List<quoteshare> lstqs = new List<quoteshare>();
        for(Quote q : Trigger.new){
            List<Opportunity> lstopp = [Select id,Name,StageName,CloseDate,ownerId from Opportunity where id =: q.OpportunityId];
            if(lstopp.size()>0){
                if(lstopp[0].ownerId != q.OwnerId){
                    quoteshare qs = new Quoteshare();
                    qs.parentid = q.Id;
                    qs.userorgroupid = lstopp[0].ownerId;
                    qs.accesslevel = 'Read';
                    lstqs.add(qs);
                }
            }
        }
        insert lstqs;
    }
}