Trigger QuoteLineTrigger on QuoteLineItem (before insert,before update) 
{
        QuoteLineTrigger_Handler.qli_M1(Trigger.New);
}