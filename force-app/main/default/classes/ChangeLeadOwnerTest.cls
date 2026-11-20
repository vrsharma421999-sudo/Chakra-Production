@isTest(SeeAllData=true)
public class ChangeLeadOwnerTest {
    static testmethod void t1(){
        test.startTest();
        lead l = new Lead();
        l.FirstName='test';
        l.LastName='lead';
        l.Company='xyz';
   //     l.ownerid='005Do0000023sLf';
        insert l;
        ChangeLeadOwner.changeOwner(l.Id);
        test.stopTest();
            
    }
}