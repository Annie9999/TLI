global class NotifyChatMessageEvent implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {

    ChatMessage__c chatmessage;
    List<LineChatMessageEvent__e> messageEvents = new List<LineChatMessageEvent__e>();

    global NotifyChatMessageEvent(ChatMessage__c chatmessage) {
        this.chatmessage = chatmessage;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Id, Name, ChatSession__c, Message_Type__c, Time_Stamp__c, Body_Message__c,ChatSession__r.Social_ID__r.Social_ID__c FROM ChatMessage__c Limit 1');
   	}
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {  
        System.debug('NotifyChatMessageEvent');
        LineChatMessageEvent__e event = new LineChatMessageEvent__e(
                                ChatSession_Id__c = chatMessage.ChatSession__c,
                                ChatMessage_Id__c = chatMessage.Id,
                                Display_Date__c = chatMessage.Time_Stamp__c.format(LineChatMainComponentRemote.DATE_FORMAT),
                                Display_Time__c = chatMessage.Time_Stamp__c.format(LineChatMainComponentRemote.TIME_FORMAT),
                                message_type__c = chatMessage.Message_Type__c,
                                Message_Owner__c = chatmessage.IsOutbound__c ? chatmessage.CreatedBy.name : (chatMessage.ChatSession__r.Social_ID__r != null ? chatMessage.ChatSession__r.Social_ID__r.Display_Name__c : 'Unknown Name'),
                                Is_Outbound__c = chatmessage.IsOutbound__c,
                                Channel_Access_Token__c = chatMessage.Channel_Access_Token__c
                                );

            System.debug('Value of event: '+event);

            switch on chatMessage.Message_Type__c {
                when 'text' {
                    event.Message__c = chatMessage.Body_Message__c;
                }
                when 'image' {
                    event.Message__c = chatMessage.Body_Message__c;
                    System.debug(event.Message__c);
                }when 'file' {
                    List<String> splitedStr = chatMessage.Body_Message__c.split(';;');
                        if (splitedStr.size() > 1) {
                            event.Message__c = splitedStr[1];
                            event.url_content__c = splitedStr[0];
                        }else {
                            event.message_type__c = 'text';
                            event.Message__c = chatMessage.Body_Message__c;
                        }
                }
                when 'sticker' {
                    event.Message__c = chatMessage.Body_Message__c;
                }
                when 'endchat' {
                    event.Message__c = chatMessage.Body_Message__c;      
                }
            }
            messageEvents.add(event);

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
    }
	
	global void finish(Database.BatchableContext BC) {
	}
}