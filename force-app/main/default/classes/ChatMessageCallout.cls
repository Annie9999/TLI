global class ChatMessageCallout implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    
    private string accessToken;
    private string chatMessageId;
    private string response;
    private ThaiLifeLineChatAPI__c config = new ThaiLifeLineChatAPI__c();
    private Boolean flow;
    private string message;

    global ChatMessageCallout(string chatMessage, ThaiLifeLineChatAPI__c configdata) {
        ChatMessageId = chatMessage;
        config = configdata;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Id, Name, ChatSession__c, Message_Type__c, Time_Stamp__c, Body_Message__c, ChatSession__r.Social_ID__r.Social_ID__c, ChatSession__r.Channel_ID__c, Reply_Token__c FROM ChatMessage__c WHERE ID =:ChatMessageId Limit 1');
   	}
    
    global void execute(Database.BatchableContext BC, List<ChatMessage__c> scope) {  
        System.debug('ChatMessageCallout');
        System.debug(config);
            if(!scope.isEmpty()) {
                for(ChatMessage__c chatMessage : scope){
                    String ENDPOINT = config.endpoint__c + '/message';
                    Map<String, String> jsonBodyMapObject = new Map<String, String>();
                    String messageType = chatMessage.Message_Type__c;
                    switch on chatMessage.Message_Type__c {
                        when 'text' {
                            jsonBodyMapObject.put('messageType', chatMessage.Message_Type__c);
                            jsonBodyMapObject.put('message', chatMessage.Body_Message__c);
                            jsonBodyMapObject.put('channel_id', chatMessage.ChatSession__r.Channel_ID__c); 
                            jsonBodyMapObject.put('replyToken', 'sf1234');
                        }
                        when 'image' {
                            jsonBodyMapObject.put('messageType', chatMessage.Message_Type__c);
                            jsonBodyMapObject.put('message', '');
                            jsonBodyMapObject.put('originalContentUrl', chatMessage.Body_Message__c);
                            jsonBodyMapObject.put('previewImageUrl', chatMessage.Body_Message__c);
                            jsonBodyMapObject.put('channel_id', chatMessage.ChatSession__r.Channel_ID__c); 
                            jsonBodyMapObject.put('replyToken', 'sf1234');
                        }when 'file' {
                            List<String> splitedStr = chatMessage.Body_Message__c.split(';;');
                            if (splitedStr.size() > 1) {
                                List<ContentDistribution> cd = [select contentDownloadUrl from ContentDistribution where ContentDocumentId = :splitedStr[0]];
                                if (cd.size() > 0) {
                                    jsonBodyMapObject.put('messageType', chatMessage.Message_Type__c);
                                    jsonBodyMapObject.put('message',  cd[0].contentDownloadUrl);
                                    jsonBodyMapObject.put('channel_id', chatMessage.ChatSession__r.Channel_ID__c); 
                                    jsonBodyMapObject.put('replyToken', 'sf1234');
                                }
                            }
                        }
                        when else {
                            jsonBodyMapObject.put('messageType', 'text');
                            jsonBodyMapObject.put('message', chatMessage.Body_Message__c);
                            jsonBodyMapObject.put('replyToken', 'sf1234');                             
                        }
                    }
                    jsonBodyMapObject.put('social_Id', chatMessage.ChatSession__r.Social_ID__r.Social_ID__c);
                    System.debug(jsonBodyMapObject);

                    HttpRequestService callout = new HttpRequestService();
                    callout.setHeader('Content-Type','application/json');
                    callout.setHeader('authorization', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJPbmxpbmUgSldUIEJ1aWxkZXIiLCJpYXQiOjE1NzUzODQ4NDQsImV4cCI6MTYwNjkyMDg0NCwiYXVkIjoid3d3LmV4YW1wbGUuY29tIiwic3ViIjoianJvY2tldEBleGFtcGxlLmNvbSJ9.9MTxT9YcAV6UVfm39KqU-FSfUPYOAQUK6UQCrR0eXRE');
                   
                    callout.setTimeout(120000);
                    callout.setSingleRequestBody(jsonBodyMapObject);
                    HttpResponse resp = null;
                    
                    try {
                        if (Test.isRunningTest() == false) {
                            resp = callout.executeCallout('POST', ENDPOINT);
                            System.debug(resp);
                            System.debug('Response: ' + resp.getBody());
                        } else if (Test.isRunningTest() == true) {
                            resp = new HttpResponse();
                            resp.setBody('[{}]');
                            resp.setStatusCode(204);
                        }
                    } catch (Exception e) {
                        System.debug('catch');
                        System.debug(e.getLineNumber());
                        System.debug(e.getMessage());
                        if (CalloutAPI_Util.isHTTP503ServiceUnavailable(e) == true) {
                            System.debug('Error 503');
                            resp = new HttpResponse();
                            resp.setStatusCode(503);
                        }
                    }

                    System.debug('===== chat message id[SESSION] =====' + chatMessage.ChatSession__c);
                    List<ChatSession__c> chatSessions = [SELECT Id,Chat_Topic__c,Others_Topic__c,Chat_Note__c,End_DateTime__c,
                                                              First_Responded_DateTime__c,IsExpired__c 
                                                      FROM ChatSession__c WHERE Id = :chatMessage.ChatSession__c limit 1];
                    System.debug('===== First res =====' +chatSessions.get(0).First_Responded_DateTime__c);
                    if (chatSessions.size() > 0) {
                        if(chatSessions.get(0).First_Responded_DateTime__c == null){
                            ChatSession__c thisSession = chatSessions[0];
                            thisSession.First_Responded_DateTime__c = System.now();
                            update thisSession;
                        }
                    }

                    if (resp != null && resp.getStatusCode() == 200) {
                        System.debug('200 OK');
                        Map<String, Object> httpResponseMapObj = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                        System.debug(httpResponseMapObj.get('result'));
                    }else if(resp != null && resp.getStatusCode() == 401) {
                        System.debug('401 Unauthorized');
                        Map<String, Object> httpResponseMapObj = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                        System.debug(httpResponseMapObj.get('result'));
                        System.debug(httpResponseMapObj);
                        response = String.valueOf(httpResponseMapObj.get('result'));
                        message = String.valueOf(httpResponseMapObj.get('message'));
                    }
                }
            }
    }
	
	global void finish(Database.BatchableContext BC) {
       
	}
}