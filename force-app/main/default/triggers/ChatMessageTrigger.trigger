trigger ChatMessageTrigger on ChatMessage__c (after insert) {
    if (trigger.isAfter) {
        if (trigger.isInsert) {      
            List<ThaiLifeLineChatAPI__c> configList = [SELECT Id, userName__c, password__c, endpoint__c, isActive__c FROM ThaiLifeLineChatAPI__c WHERE isActive__c = true Limit 1];	
            System.debug(configList);      
            for (ChatMessage__c chatMessage : trigger.new) {
                System.debug(chatMessage);
                if (chatMessage.IsOutbound__c == true && (!configList.isEmpty())) {
                    ChatMessageCallout callout;
                    callout = new ChatMessageCallout(chatMessage.Id, configList.get(0));
                    Database.executeBatch(callout);

                }
                /* -- create chat message events and add them into list-- */
                if (chatMessage.IsOutbound__c == false && ChatMessage.Message_Type__c != 'expired') {
                    Database.executeBatch(new NotifyChatMessageEvent(chatMessage));
                }
            }
        }
    }
}