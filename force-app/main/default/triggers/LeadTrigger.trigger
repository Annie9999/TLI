trigger LeadTrigger on Lead (before insert,before update) {
     
    if (Trigger.isUpdate && Trigger.isBefore) {
        LeadTriggerHandler.handleBeforeUpdate(Trigger.new);
    } 

}