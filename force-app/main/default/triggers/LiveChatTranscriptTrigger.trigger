trigger LiveChatTranscriptTrigger on LiveChatTranscript (after update) {

    if(Trigger.isAfter && Trigger.isUpdate){
          System.debug('######## Start LiveChatTranscriptTrigger After Update ########');
          LiveChatTranscriptTriggerHandler.handleAfterUpdate(Trigger.new);
    }

}