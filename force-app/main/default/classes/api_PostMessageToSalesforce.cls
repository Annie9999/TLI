@RestResource(urlMapping = '/postMessageToSalesforce')
global class api_PostMessageToSalesforce{
     @HttpPost
    global static void main(){
        System.debug('========== postMessageToSalesforce ==========');

        //response
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');

        //request
        String requestString;
        RestRequest request = RestContext.request;

        //Extract string from requestBody
        Blob body = request.requestBody;
        requestString = body.toString();

        Map<String, Object> mapResult = (Map<String,Object>)JSON.deserializeUntyped(requestString);
        System.debug(mapResult);
        System.debug('========== LINE ID ========== '+mapResult.get('lineId'));

        String lineId = String.valueOf(mapResult.get('lineId'));
        List<SocialAccount__c> lineAccountList = [SELECT Id, Avatar_URL__c, Display_Name__c, Social_ID__c, Social_type__c FROM SocialAccount__c WHERE Social_ID__c = :lineId];
        Map<String, SocialAccount__c> lineAccountMapping = new Map<String, SocialAccount__c>();
        System.debug('========== lineAccountList ========== '+ lineAccountList);

        if(!lineAccountList.isEmpty()){
            for(SocialAccount__c lineAccount: lineAccountList ){
                lineAccountMapping.put(lineAccount.Social_ID__c, lineAccount);
            }
        }
        //Step1
        System.debug('========== lineAccountMapping ========== '+ lineAccountMapping);
        String line_Id = '';
        if(!lineAccountMapping.containsKey(lineId)){
            //Create Line Account 
            System.debug('========== No line account ==========');
            SocialAccount__c lineAccount = new SocialAccount__c();
            lineAccount.Social_ID__c = String.valueOf(mapResult.get('lineId'));
            lineAccount.Display_Name__c = String.valueOf(mapResult.get('displayName'));
            lineAccount.Avatar_URL__c = String.valueOf(mapResult.get('avatarURL'));
            lineAccount.Social_type__c = String.valueOf(mapResult.get('socialType'));
            System.debug('========== set Line Account in Salesforce ========= '+ lineAccount);

            insert lineAccount;
            line_Id = lineAccount.Id;
        }else{
            System.debug('========== have line account ==========');
            line_Id = String.valueOf(lineAccountList.get(0).Id);
        }

        //Create Line Session
        String sessionID;
        String agentId = String.valueOf(mapResult.get('message'));
        System.debug('========== Agent Id ========== '+ agentId);

        //Check session (Step2) get session_id
        DateTime currentTime = System.now();
        List<chatSession__c> checkExpireList = [SELECT Id, SessionID__c, Social_ID__r.Social_ID__c, IsExpired__c, Expired_DateTime__c FROM ChatSession__c WHERE Social_ID__c  = :line_Id AND IsExpired__c = false AND Expired_DateTime__c >= :currentTime];
        if (!checkExpireList.isEmpty()){
            //Step3 LINE Message bind Session_Id(checkExpireList) from step2 
            // create chat message 
            ChatMessage__c chatMessage = new ChatMessage__c();      
            chatMessage.Message_Type__c = String.valueOf(mapResult.get('messageType'));
            chatMessage.Sender__c = String.valueOf(mapResult.get('lineId'));
            chatMessage.Channel_Access_Token__c = String.valueOf(mapResult.get('channelAccessToken'));
            chatMessage.Reply_Token__c = String.valueOf(mapResult.get('replyToken'));
            switch on chatMessage.Message_Type__c {
                when 'file' {
                    chatMessage.Body_Message__c = String.valueOf(mapResult.get('message')) + ';;' + String.valueOf(mapResult.get('fileName')); 
                }
                when else {
                    chatMessage.Body_Message__c = String.valueOf(mapResult.get('message'));
                }
            }
            chatMessage.ChatSession__c = checkExpireList.get(0).Id;
            chatMessage.Time_Stamp__c = System.now();
            chatMessage.IsOutbound__c = false;
            
            System.debug('========== Chat Message ========='+chatMessage);
            insert chatMessage;
            
            // update expired date time
            List<LineChatSesstionExpiredDateTime__mdt> addMinutesExpired = [SELECT Id, Label, addMinutes__c FROM LineChatSesstionExpiredDateTime__mdt WHERE Label = 'active'];
            Integer minute = Integer.valueOf(addMinutesExpired.get(0).addMinutes__c );
            checkExpireList.get(0).Expired_DateTime__c = (System.now().addMinutes(minute));
            update checkExpireList;

            // response to webhook
            response.statusCode = 200;
            response.responseBody = Blob.valueOf('{"result" : "success"}');

        }else{
            //create session
            sessionID = getUUID();
            System.debug(sessionID);
            List<LineChatSesstionExpiredDateTime__mdt> addMinutesExpired = [SELECT Id, Label, addMinutes__c FROM LineChatSesstionExpiredDateTime__mdt WHERE Label = 'active'];
            DefaultLineChatQueue__c defaultQueueName = [SELECT Id, Queue_Name__c FROM DefaultLineChatQueue__c LIMIT 1];
            // string channelId = String.valueOf(mapResult.get('channelId'));
            // System.debug('=== channelId ===' + channelId);
            // DefaultLineChatQueue__c defaultQueueName = [SELECT Id, Queue_Name__c FROM DefaultLineChatQueue__c WHERE Channel_ID__c = :channelId LIMIT 1];
            // System.debug('=== defaultQueueName ===' + defaultQueueName);
            Integer minute = Integer.valueOf(addMinutesExpired.get(0).addMinutes__c );
            //check duplicate session
            String chatExternalID = line_Id + '_Is_Active';
            System.debug('=== Chat External ID ===' + chatExternalID);
            ChatSession__c chatSession = new ChatSession__c();
            chatSession.Social_ID__c = line_Id;
            chatSession.SessionID__c = sessionID;
            chatSession.chatSession_External_ID__c = chatExternalID;
            chatSession.Expired_DateTime__c = (System.now().addMinutes(minute));
            chatSession.OwnerId = getQueue(defaultQueueName != null ? defaultQueueName.Queue_Name__c : '');
            System.debug('=== chatSession OwnerId ===' + chatSession.OwnerId);
            chatSession.Name = String.valueOf(mapResult.get('displayName')) + ' has requested a Line Chat';
            chatSession.Channel_ID__c = mapResult.containsKey('channelId') ? String.valueOf(mapResult.get('channelId')) : null;
            chatSession.Channel_Name__c = mapResult.containsKey('channel_name') ? String.valueOf(mapResult.get('channel_name')) : null;
            try{
                System.debug('=== insert 1st LINE Session ===');
                insert chatSession;
                 //create message
                ChatMessage__c chatMessage = new ChatMessage__c();      
                chatMessage.Message_Type__c = String.valueOf(mapResult.get('messageType'));
                chatMessage.Sender__c = String.valueOf(mapResult.get('lineId'));
                chatMessage.Channel_Access_Token__c = String.valueOf(mapResult.get('channelAccessToken'));
                chatMessage.Reply_Token__c = String.valueOf(mapResult.get('replyToken'));
                switch on chatMessage.Message_Type__c {
                    when 'file' {
                        chatMessage.Body_Message__c = String.valueOf(mapResult.get('message')) + ';;' + String.valueOf(mapResult.get('fileName')); 
                    }
                    when else {
                        chatMessage.Body_Message__c = String.valueOf(mapResult.get('message'));
                    }
                }
                chatMessage.ChatSession__c = chatSession.Id;
                chatMessage.Time_Stamp__c = System.now();
                chatMessage.IsOutbound__c = false;
                System.debug('========== Chat Message ========='+chatMessage);
                insert chatMessage;

            }catch(Exception e){
                System.debug('=== Duplicate LINE Session === ' + e.getMessage());
            }
            
            // response to webhook
            response.statusCode = 200;
            response.responseBody = Blob.valueOf('{"result" : "success"}');
        }
    }
    
    public static String getUUID(){
        Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
		return guid;
	}

    public static Id getQueue(String name){
        System.debug('=== name ===' + name);

        Id OwnerIdtemp;
        Group groupTemp = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :name LIMIT 1];
        OwnerIdtemp = groupTemp.Id;

        System.debug('=== getQueue ==='+OwnerIdtemp);
        return OwnerIdtemp;
    }
}