@isTest
public class CurrencyConvertor_Test {
    static testMethod Void PDFTest()
    {
        Test.startTest();
        currencyConvertor obj = new currencyConvertor();
        obj.Convert(1000.89);
        obj.Convert(100055.99);
        obj.Convert(1000.777);
        obj.Convert(1.0);
        obj.Convert(10);
        obj.Convert(200.5528888);
        obj.Convert(3.3475);
        obj.Convert(60.150);
        obj.Convert(90777);
        obj.Convert(0.0);
        obj.Convert(32183791.0);
        obj.Convert(32889.0);
        Test.stopTest();
    }
}