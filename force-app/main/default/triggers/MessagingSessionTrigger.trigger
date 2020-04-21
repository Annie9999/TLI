trigger MessagingSessionTrigger on MessagingSession (before insert, after insert,before update, after update) {

    if (Trigger.isInsert && Trigger.isBefore) {
        System.debug('MessagingSessionTrigger : handleBeforeInsert');
        MessagingSessionTriggerHandler.handleBeforeInsert(Trigger.new);
    } else if (Trigger.isUpdate && Trigger.isAfter) {
        System.debug('MessagingSessionTrigger : handleAfterUpdate');
        MessagingSessionTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);      
    }
    
}