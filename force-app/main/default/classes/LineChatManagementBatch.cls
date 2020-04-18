global class LineChatManagementBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    public static String EXPIRED_MESSAGE = 'Session is Expired';

    global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Id,Name, OwnerId, IsExpired__c, SessionID__c, Expired_DateTime__c FROM ChatSession__c WHERE IsExpired__c = false');
   	}
    
    global void execute(Database.BatchableContext BC, List<ChatSession__c> scope) {
        System.debug('scope ' + scope);
        if(!scope.isEmpty()) {
            List<ChatSession__c> listChatSessionUpdate = new List<ChatSession__c>();
            List<ChatMessage__c> listNewChatMessageExpired = new List<ChatMessage__c>();
            List<LineChatMessageEvent__e> messageEvents = new List<LineChatMessageEvent__e>();
            List<Task> notiExpiredTasks = new List<Task>();
           
			for(ChatSession__c chatSession : scope){
                if (ChatSession.Expired_DateTime__c < System.now()) {
                    chatSession.chatSession_External_ID__c = api_PostMessageToSalesforce.getUUID()+'_'+ System.now();
                    chatSession.IsExpired__c = true;
                    chatSession.End_DateTime__c = System.now();
                    listChatSessionUpdate.add(chatSession);

                    ChatMessage__c chatMessage = new ChatMessage__c();
                    chatMessage.Body_Message__c = EXPIRED_MESSAGE;
                    chatMessage.Time_Stamp__c = System.now();
                    chatMessage.Message_Type__c = 'expired';
                    chatMessage.ChatSession__c = chatSession.Id;
                    chatMessage.IsOutbound__c = false;
                    listNewChatMessageExpired.add(chatMessage);

                }
            }
            if (!listChatSessionUpdate.isEmpty()) {
                update listChatSessionUpdate;
            }
            if (!listNewChatMessageExpired.isEmpty()) {
                insert listNewChatMessageExpired;
                for (ChatMessage__c each : listNewChatMessageExpired) {
                    messageEvents.add(new LineChatMessageEvent__e(
                        ChatSession_Id__c = each.ChatSession__c,
                        ChatMessage_Id__c = each.Id,
                        isExpired__c = 'true',
                        message_type__c = each.Message_Type__c,
                        Is_Outbound__c = each.IsOutbound__c,
                        Display_Date__c = each.Time_Stamp__c.format(LineChatMainComponentRemote.DATE_FORMAT),
                        Display_Time__c = each.Time_Stamp__c.format(LineChatMainComponentRemote.TIME_FORMAT)
                        ));
                }
            }
            System.debug('messageEvents ' + messageEvents);
            /* --send chat message events out to Component-- */
            if (messageEvents.size() > 0) {
                List<Database.SaveResult> results = EventBus.publish(messageEvents);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        for (Database.Error error : result.getErrors()) {
                            System.debug('Error returned: ' + error.getStatusCode() +' - '+ error.getMessage());
                        }
                    }
                }
            }
            /* End --send chat message events out to Component-- */

            /* --send notification to chat session owner-- */
            if (notiExpiredTasks.size() > 0) {
                insert notiExpiredTasks;
                LineChatMainComponentRemote.postToChatter(notiExpiredTasks);
            }
            /* End --send notification to chat session owner-- */

        }
	    
    }
	
	global void finish(Database.BatchableContext BC) {
		
	}
}