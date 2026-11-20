Trigger leadConvertedSendEmail on Lead (after update)
{
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        leadConvertedSendEmailClass.sendEmail(Trigger.new, trigger.oldmap);
    }
}