trigger TaskTrigger on Task (before insert, after insert) {
    
    if (Trigger.isInsert && Trigger.isBefore) {
        TaskTriggerHandler.handleBeforeInsert(Trigger.new);
    } 

    if (Trigger.isInsert && Trigger.isAfter) {
        TaskTriggerHandler.handleAfterInsert(Trigger.new);
    } 

}