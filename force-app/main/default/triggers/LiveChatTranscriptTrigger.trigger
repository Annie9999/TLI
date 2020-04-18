trigger LiveChatTranscriptTrigger on LiveChatTranscript (after update) {

    if(Trigger.isUpdate && Trigger.isAfter){
          System.debug('######## Start LiveChatTranscriptTrigger After Update ########');
          LiveChatTranscriptTriggerHandler.handleAfterUpdate(Trigger.new);
    }

}