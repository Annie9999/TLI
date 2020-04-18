public with sharing class LineChatMainComponentRemote {
    public static String DATE_FORMAT = 'EEE, d MMM yyyy';
	public static String TIME_FORMAT = 'HH:mm';
	public static Integer MAX_RECORD_OF_MESSAGE = 15;
    public static List<String> IMAGE_SUFFIX = new List<String>{
		'jpg','png','jpeg'
	};
    public static String PREFIX_IMG = 'data:image/png;base64, ';

    public class MessageInTime{
      @AuraEnabled
      public String timeStamp {get;set;}
      @AuraEnabled
      public String owner {get;set;}
      @AuraEnabled
      public String ownerName {get;set;}
      @AuraEnabled
      public String text {get;set;} 
      @AuraEnabled
      public String type {get;set;} 
      @AuraEnabled
      public String urlContent {get;set;} 
 
    }
    public class MessageCollectionInDay{
      @AuraEnabled
      public String sentDate {get;set;}
      @AuraEnabled
      public List<MessageInTime> messages {get;set;}
      
      public MessageCollectionInDay(String sentDate, List<MessageInTime> messages){
        this.sentDate = sentDate;
        this.messages = messages;
      }
    }

    public class ResponseGetInitData{
       @AuraEnabled
      public String clientName {get;set;}
      	@AuraEnabled
      public String socialName {get;set;}
      	@AuraEnabled
      public User provider {get;set;}
       @AuraEnabled
      public String lastDateSession {get;set;}
        @AuraEnabled
      public ChatSession__c chatSession {get;set;}
      	@AuraEnabled
      public List<MessageCollectionInDay> messageCollection {get;set;}
      	@AuraEnabled
      public Boolean isHasPreviousMessage {get;set;}
      	@AuraEnabled
      public ChatMessage__c previousMessage {get;set;}
       @AuraEnabled
      public List<String> chatMessageIdList {get;set;}
      	@AuraEnabled
      public Boolean isDisableInput {get;set;}
    }

    @AuraEnabled
	public static ResponseGetInitData getInitData(String recordId){
        ResponseGetInitData responseData = new ResponseGetInitData();
        getChatCollectionData(recordId,responseData,null);

        return responseData;
    }

    @AuraEnabled
	public static ResponseGetInitData getMoreData(String recordId,ChatMessage__c previosChatmessage){
        System.debug('previos ' + previosChatmessage);
        ResponseGetInitData responseData = new ResponseGetInitData();
        getChatCollectionData(recordId,responseData,previosChatmessage);
       
        return responseData;
    }
	private static void getChatCollectionData(String recordId,ResponseGetInitData responseData,ChatMessage__c previousMessage){
        List<MessageCollectionInDay> results = new List<MessageCollectionInDay>();
        User currentUser = GlobalUtility.getCurrentUser();
        String clientName;
        String socialName;
        ChatSession__c chatSession;
        responseData.isHasPreviousMessage = false;
        List<ChatMessage__c> chatMessages = new  List<ChatMessage__c>();
        List<ChatSession__c> chatSessionUser = [SELECT Owner.Id, Owner.Name, Social_ID__r.Display_Name__c,
                                            Social_ID__r.Owner.Id, Social_ID__r.Owner.Name, IsExpired__c, Social_ID__r.Social_ID__c,
                                            CreatedDate, Chat_Note__c FROM ChatSession__c WHERE Id = :recordId ];

        //get user line id
        System.debug('==========User LINE ID: '+ chatSessionUser[0].Social_ID__r.Social_ID__c);
    

        List<String> chatMessageIds = new  List<String>();
        if (previousMessage == null) {
            chatMessages = [SELECT Id, Body_Message__c, Sender__c, Time_Stamp__c, Message_Type__c, Channel_Access_Token__c, createdBy.Id, createdBy.name,
                                             IsOutbound__c, ChatSession__r.Owner.Id, ChatSession__r.Owner.Name, ChatSession__r.Social_ID__r.Display_Name__c,
                                             ChatSession__r.Social_ID__r.Owner.Id, ChatSession__r.Social_ID__r.Owner.Name, ChatSession__r.IsExpired__c,
                                             ChatSession__r.CreatedDate,ChatSession__r.Chat_Note__c
                                            FROM ChatMessage__c 
                                            Where ChatSession__r.Social_ID__r.Social_ID__c = :chatSessionUser[0].Social_ID__r.Social_ID__c
                                            Order by Time_Stamp__c DESC limit : MAX_RECORD_OF_MESSAGE+1];
     
        }else {
            chatMessages = [SELECT Id, Body_Message__c, Sender__c, Time_Stamp__c, Message_Type__c, Channel_Access_Token__c, createdBy.Id, createdBy.name,
                                             IsOutbound__c, ChatSession__r.Owner.Id, ChatSession__r.Owner.Name, ChatSession__r.Social_ID__r.Display_Name__c,
                                             ChatSession__r.Social_ID__r.Owner.Id, ChatSession__r.Social_ID__r.Owner.Name, ChatSession__r.IsExpired__c,
                                             ChatSession__r.CreatedDate,ChatSession__r.Chat_Note__c
                                            FROM ChatMessage__c 
                                            Where ChatSession__r.Social_ID__r.Social_ID__c = :chatSessionUser[0].Social_ID__r.Social_ID__c and Time_Stamp__c <= :previousMessage.Time_Stamp__c and Id != :previousMessage.Id
                                            Order by Time_Stamp__c DESC limit : MAX_RECORD_OF_MESSAGE+1];

            if (chatMessages.size() < 1) {
                chatMessages.add(previousMessage);
            }else {
                chatMessages.add(0,previousMessage);
            }
        }
        System.debug('chatMessage ' + chatMessages);
        System.debug('chatMessage ' + chatMessages.size());
        if (chatMessages.size() > 0) {
            if (chatMessages.size() > MAX_RECORD_OF_MESSAGE) {
                responseData.isHasPreviousMessage = true;
                responseData.previousMessage = chatMessages.remove(MAX_RECORD_OF_MESSAGE);
            }
            System.debug('responseData.previousMessage' +  responseData.previousMessage);
            chatMessages = reIndexList(chatMessages);
            DateTime thisDate = chatMessages[0].Time_Stamp__c;
            chatSession = chatSessionUser[0];
            List<MessageInTime> messageOnThisDay = new List<MessageInTime>();
            socialName = chatMessages[0].ChatSession__r != null 
                        && chatMessages[0].ChatSession__r.Social_ID__r != null ?
                        chatMessages[0].ChatSession__r.Social_ID__r.Display_Name__c : null;

            for (ChatMessage__c eachMessage : chatMessages) {
                chatMessageIds.add(eachMessage.Id);
                MessageInTime message = new MessageInTime();
                message.timeStamp = eachMessage.Time_Stamp__c.format(TIME_FORMAT);
                message.owner = eachMessage.IsOutbound__c ? 'provider' : 'client' ;
                
                clientName = clientName == null && !eachMessage.IsOutbound__c ? eachMessage.ChatSession__r.Social_ID__r.owner.Id : null;
                
                message.ownerName = eachMessage.IsOutbound__c ? eachMessage.createdBy.name : socialName ;
                message.type = eachMessage.Message_Type__c;
                switch on eachMessage.Message_Type__c {
                    when 'text' {
                        message.text = eachMessage.Body_Message__c;
                    }
                    when 'image' {
                        message.text =  eachMessage.IsOutbound__c ? eachMessage.Body_Message__c : getImageFromLine(eachMessage.Body_Message__c, eachMessage.Channel_Access_Token__c);
                    }
                     when 'file' {
                        List<String> splitedStr = eachMessage.Body_Message__c.split(';;');
                        if (splitedStr.size() > 1) {
                                if (eachMessage.IsOutbound__c) {
                                    ContentDistribution cd = getContentDistributionDetail(splitedStr[0]);
                                    if (cd != null) {
                                        message.text =  splitedStr[1];
                                        message.urlContent = cd.contentDownloadUrl;
                                    }
                                }else {
                                    message.text = splitedStr[1];
                                    message.urlContent = splitedStr[0];
                                }
                        }
                    }
                    when 'transfer' {
                        List<String> splitedStr = eachMessage.Body_Message__c.split('->');
                        message.text =splitedStr[0];
                        message.owner = splitedStr.size() > 1 ? splitedStr[1] : ''; 
                        message.ownerName = eachMessage.createdBy.name ;
                    }
                    when 'endchat' {
                        message.text = eachMessage.Body_Message__c;
                        message.ownerName = eachMessage.Body_Message__c.contains('Expired') ? '' : eachMessage.createdBy.name ;
                    }
                    when else {
                        message.text = eachMessage.Body_Message__c;
                    }
                    
                }
                if(eachMessage.Time_Stamp__c.Date() == thisDate.Date()) {
                    messageOnThisDay.add(message);
                } else {
                    results.add(new MessageCollectionInDay(thisDate.format(DATE_FORMAT),
                                                            messageOnThisDay));
                    
                    messageOnThisDay = new List<MessageInTime>();

                    messageOnThisDay.add(message);
                    thisDate = eachMessage.Time_Stamp__c;
                }
                
            }


            results.add(new MessageCollectionInDay(thisDate.format(DATE_FORMAT),
                                                    messageOnThisDay));
            

            responseData.lastDateSession = thisDate.format(DATE_FORMAT);
        }
   
        responseData.messageCollection = results; 
        
        responseData.clientName = clientName;
        responseData.socialName = socialName;
        responseData.provider = currentUser;
        responseData.chatSession = chatSession;
        responseData.chatMessageIdList = chatMessageIds;
        responseData.isDisableInput = currentUser.Id != chatSession.Owner.Id || chatSession.IsExpired__c;
        System.debug('==============chat Session is Expire '+chatSession.IsExpired__c);
       
    }

	private static List<ChatMessage__c> reIndexList(List<ChatMessage__c> chatMessages){
        List<ChatMessage__c> result = new List<ChatMessage__c>();
        result.add(chatMessages.remove(0));
        for (ChatMessage__c cm : chatMessages) {
            result.add(0,cm);
        }
        return result;
    }
    public class MessageModel{
        @AuraEnabled
        public String messageType {get;set;}
        @AuraEnabled
        public String sender {get;set;}
        @AuraEnabled
        public String text {get;set;} 
     }

     public class ResponseSaveMessage{
        @AuraEnabled
        public String messageType {get;set;}
        @AuraEnabled
        public Boolean isSuccess {get;set;}
        @AuraEnabled
        public String url {get;set;} 
        @AuraEnabled
        public String fileName {get;set;}
         @AuraEnabled
        public String chatMessageId {get;set;}
     }

    @AuraEnabled
	public static ResponseSaveMessage saveMessageObject(String recordId,String messageStringModel){
        ResponseSaveMessage res = new ResponseSaveMessage();
        
		MessageModel messageModel = (MessageModel)JSON.deserialize(messageStringModel, MessageModel.class);
        System.debug('model ' + messageModel);
        switch on messageModel.messageType {
            when 'text' {
                res.chatMessageId = insertTextMessage(recordId,messageModel);
            }
            when 'imagefile' {
                    ContentVersion cv = getContentVersionDetail(messageModel.text);
                    if (cv != null) {
                        if (IMAGE_SUFFIX.contains(cv.contentdocument.fileExtension)) {
                            messageModel.messageType = 'image';
                        }else {
                            messageModel.messageType = 'file';
                        }
                         /** messageModel.text as document id */
                        ContentDistribution cd = makePublicFile(messageModel.text,messageModel ,cv);
                        if (messageModel.messageType == 'image') {
                            res.chatMessageId = insertImageMessage(cd.contentDownloadUrl,recordId,messageModel);
                            res.isSuccess = true;
                            res.url = cd.contentDownloadUrl;
                            res.messageType = messageModel.messageType;
                        }else {
                            String fileName = cv.contentdocument.Title + '.' + cv.contentdocument.fileExtension;
                            res.chatMessageId = insertFileMessage(fileName,recordId,messageModel);
                            res.isSuccess = true;
                            res.url = cd.contentDownloadUrl;
                            res.fileName = fileName;
                            res.messageType = messageModel.messageType;
                        }
                    }
            }
            when else {
                
            }
        }
        return res;
    }

    private static String insertTextMessage(String recordId, MessageModel messageModel){
        // check expire chat session
        ChatMessage__c chatMessage = new ChatMessage__c();
        chatMessage.Body_Message__c = messageModel.text;
        chatMessage.Sender__c = messageModel.sender;
        chatMessage.Time_Stamp__c = System.now();
        chatMessage.Message_Type__c = messageModel.messageType;
        chatMessage.ChatSession__c = recordId;
        chatMessage.IsOutbound__c = true;

        insert chatMessage;
        return chatMessage.Id;
    }

    public static ContentVersion getContentVersionDetail(String documentId){
        List<ContentVersion> cv = [select id, contentdocument.fileExtension, contentdocument.Title from contentversion where contentdocumentid = :documentId];
        if (cv.size() > 0) {
            return cv[0];
        }
        return null;
    }

    public static ContentDistribution getContentDistributionDetail(String documentId){
            List<ContentDistribution> cd = [select DistributionPublicUrl, contentDownloadUrl from ContentDistribution where ContentDocumentId = :documentId];
            if (cd.size() > 0) {
                return cd[0];
            }
            return null;
    }

    public static ContentDistribution makePublicFile(String documentId, MessageModel messageModel, ContentVersion cv){

        ContentDistribution cd = new ContentDistribution();
        cd.Name = String.valueOf(cv.id);
        cd.ContentVersionId = cv.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
        
        ContentDocument doc = [select id, Title from ContentDocument where id = :documentId];
        doc.Title += ' (Line-Chat Uploaded)';
        update doc;

        ContentDistribution newcd = getContentDistributionDetail(documentId);
       
        return newcd;
    }

    public static String insertImageMessage(String url, String recordId, MessageModel messageModel){
        ChatMessage__c chatMessage = new ChatMessage__c();
        chatMessage.Body_Message__c = url;
        chatMessage.Sender__c = messageModel.sender;
        chatMessage.Time_Stamp__c = System.now();
        chatMessage.Message_Type__c = messageModel.messageType;
        chatMessage.ChatSession__c = recordId;
        chatMessage.IsOutbound__c = true;

        insert chatMessage;
        return chatMessage.Id;
    }

    public static String insertFileMessage(String fileName, String recordId, MessageModel messageModel){
        ChatMessage__c chatMessage = new ChatMessage__c();
        chatMessage.Body_Message__c = messageModel.text + ';;' + fileName;
        chatMessage.Sender__c = messageModel.sender;
        chatMessage.Time_Stamp__c = System.now();
        chatMessage.Message_Type__c = messageModel.messageType;
        chatMessage.ChatSession__c = recordId;
        chatMessage.IsOutbound__c = true;

        insert chatMessage;
        return chatMessage.Id;

    }    

    @AuraEnabled
	public static String updateChatSessionIfEndChatOccured(String recordId, String chatTopic, String othersTopic, String chatNote,  String messageStringModel ,Boolean isAutoExpired){
        System.debug('updateChatSessionIfEndChatOccured');
        System.debug('messageStringModel' + messageStringModel);
        System.debug('isAutoExpired' + isAutoExpired);
        MessageModel messageModel = (MessageModel)JSON.deserialize(messageStringModel, MessageModel.class);
         List<ChatMessage__c> chatMessages = [SELECT Id,Time_Stamp__c 
                                                FROM ChatMessage__c 
                                                WHERE chatSession__c = :recordId and isOutBound__c = true 
                                                ORDER BY CreatedDate limit 1];
            
        List<ChatSession__c> chatSessions = [SELECT Id,Chat_Topic__c,Others_Topic__c,Chat_Note__c,End_DateTime__c,
                                                    First_Responded_DateTime__c,IsExpired__c 
                                                FROM ChatSession__c WHERE Id = :recordId limit 1];
        String chatMessageId;
        if (chatSessions.size() > 0) {
            ChatSession__c thisSession = chatSessions[0];
            thisSession.chatSession_External_ID__c = api_PostMessageToSalesforce.getUUID()+'_'+ System.now();
            thisSession.Chat_Topic__c = chatTopic;
            thisSession.Others_Topic__c = othersTopic;
            thisSession.Chat_Note__c = chatNote == ''? null  : chatNote;
            thisSession.IsExpired__c = true;
            thisSession.End_DateTime__c = System.now();
            thisSession.First_Responded_DateTime__c = chatMessages.size() > 0 ? chatMessages[0].Time_Stamp__c : null;
           
            update thisSession;
            if (!isAutoExpired && !chatSessions[0].IsExpired__c) {
                chatMessageId = insertSystemMessage(recordId, messageModel);
            }
        }
        return chatMessageId;
    }

     @AuraEnabled
	public static String updateChatSessionIfTransferChatOccured(String recordId, String newOwnerId, String transferMessage, String newOwnerType,
                        String messageStringModel){
         MessageModel messageModel = (MessageModel)JSON.deserialize(messageStringModel, MessageModel.class);
        List<ChatSession__c> chatSessions = [SELECT Id, Transfer_Message__c, OwnerId, Social_ID__r.Display_Name__c
                                                FROM ChatSession__c WHERE Id = :recordId limit 1];

        String chatMessageId;
        if (chatSessions.size() > 0) {
            ChatSession__c thisSession = chatSessions[0];
            thisSession.Transfer_Message__c = transferMessage;
            thisSession.OwnerId = newOwnerId;
            
            update thisSession;
            chatMessageId = insertSystemMessage(recordId, messageModel);

        }
        return chatMessageId;
    }

     private static String insertSystemMessage(String recordId, MessageModel messageModel){
        ChatMessage__c chatMessage = new ChatMessage__c();
        chatMessage.Body_Message__c = messageModel.text;
        chatMessage.Sender__c = messageModel.sender;
        chatMessage.Time_Stamp__c = System.now();
        chatMessage.Message_Type__c = messageModel.messageType;
        chatMessage.ChatSession__c = recordId;
        chatMessage.IsOutbound__c = true;

        insert chatMessage;
        return chatMessage.Id;
    }

    @AuraEnabled
	public static String getImageFromLine(String url,String token){
        
        HttpRequestService callout = new HttpRequestService();
        HttpResponse resp = new HttpResponse();
        callout.setHeader('Content-Type','image/jpeg');
        callout.setHeader('Authorization', 'Bearer ' + token);
        callout.setTimeout(120000);

        resp = callout.executeCallout('GET', url);

        String prefixImg = 'data:image/png;base64, ';
        Blob imgBlop = resp.getBodyAsBlob();
        System.debug('imgBlop '+ imgBlop );
        String imgString = EncodingUtil.base64Encode(imgBlop);
        System.debug('imgString '+ imgString );
            
       
        return PREFIX_IMG + imgString;
    }

    @AuraEnabled
	public static ContentVersion getDownloadLinkImage(String blobString,String fileName){
         System.debug('GET DOWNLOAD LINK IMAGE!!!');
        System.debug('blobString.remove(PREFIX_IMG) ' + blobString.remove(PREFIX_IMG));
        Blob blopData = EncodingUtil.base64Decode(blobString.remove(PREFIX_IMG));
        System.debug('blopData ' + blopData);
        
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.Origin = 'H'; //C-Content Origin. H-Chatter Origin.
        cVersion.Title = fileName; //Name of the file
        cVersion.PathOnClient = fileName; //File name with extention
        cVersion.VersionData = blopData;//File content
        
        insert cVersion;
        System.debug(cVersion.Id);
       
        return cVersion;
    }


     @AuraEnabled
	public static ContentVersion getFileFromLine(String url,String fileName,String token){
        
        token = '11f+ek6NGHowPb8gD/HUQm9lqE3ekA2QJpvUzqESLwgFuZak2O1IMbg3sOjYahwA/z1jGL+y9yuUaLZMXFL4vFeXmfofwMa1ZZ31DYaWk3EKyxFfLmjDhi84ZtkABEB3AxULG5VuFGyTWoatYNSeCQdB04t89/1O/w1cDnyilFU=';
        HttpRequestService callout = new HttpRequestService();
        HttpResponse resp = new HttpResponse();
        callout.setHeader('Authorization', 'Bearer ' + token);
        callout.setTimeout(120000);

        resp = callout.executeCallout('GET', url);
    

        Blob blopData = resp.getBodyAsBlob();

        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.Origin = 'H'; //C-Content Origin. H-Chatter Origin.
        cVersion.Title = fileName; //Name of the file
        cVersion.PathOnClient = fileName; //File name with extention
        cVersion.VersionData = blopData;//File content
        
        insert cVersion;
        System.debug(cVersion.Id);
       
        return cVersion;
    }

    @AuraEnabled
	public static void removeFileFromLine(String Id){
        List<ContentDocument> cVersion = [select Id from ContentDocument where Id IN (select ContentDocumentId from ContentVersion where Id = :Id)];
        delete cVersion;
    }

    public static void postToChatter(List<Task> taskList) {
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            for(Task t : taskList) {
                String sfURL = System.Url.getSalesforceBaseUrl().toExternalForm();
                String subject = t.Subject + '\r\n\t' + sfURL + '/' + t.whatId; 
                if(!Test.isRunningTest()){
                    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                    input.subjectId = t.OwnerId;
                    ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
                    body.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                    textSegment.text = subject;

                    body.messageSegments.add(textSegment);
                    input.body = body;

                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                    batchInputs.add(batchInput);
                }
            }
            if(!Test.isRunningTest()) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
        }
}