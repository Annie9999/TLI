trigger MessagingSessionTrigger on MessagingSession (after insert, after update) {
    for (MessagingSession session : Trigger.new) {
        if (Trigger.isInsert) {
            MessagingSessionTriggerHandler.MessagingSessionTrigger(session.Id);
        }
    
        if (Trigger.isUpdate) {
            // if(trigger.oldMap.get(session.Id).OwnerId != session.OwnerId){
                MessagingSessionTriggerHandler.UpdateServiceRequestOwner(session.Id);
            // }        
        }
    }


}