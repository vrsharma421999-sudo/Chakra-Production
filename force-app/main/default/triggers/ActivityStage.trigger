trigger ActivityStage on Task (before insert) 
{
	ActivityStageHandler.DealStage(Trigger.new);
}