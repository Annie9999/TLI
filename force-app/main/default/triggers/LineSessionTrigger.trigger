trigger LineSessionTrigger on ChatSession__c (before insert, after update) {

    if (Trigger.isInsert && Trigger.isBefore) {
        System.debug('LineSessionTrigger : handleBeforeInsert');
        LineSessionTriggerHandler.handleBeforeInsert(Trigger.new);
    } else if (Trigger.isUpdate && Trigger.isAfter) {
        System.debug('LineSessionTrigger : handleAfterUpdate');
        LineSessionTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);      
    }   

}