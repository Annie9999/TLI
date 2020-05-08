public without sharing class getGroupController {

    @AuraEnabled
    public static string getStatus(Id leadId){
        Lead leadObj = [SELECT id,Status
                        FROM Lead
                        WHERE id = : leadId];
        return leadObj.Status;     
        
    }
    
    @AuraEnabled 
    public static User getUserName(){
        QUEUE_NAME__mdt Queue_Name = [SELECT Queue_Name__c FROM QUEUE_NAME__mdt LIMIT 1]; 
        System.debug('Queue= '+Queue_Name.Queue_Name__c);
        Group groupId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name =: Queue_Name.Queue_Name__c  LIMIT 1];
        List<GroupMember> groupMB = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =:groupId.Id];
        integer randomInd = Integer.valueOf(Math.random() * groupMB.size());
        User user = [SELECT Id,Name FROM User WHERE id =: groupMB[randomInd].UserOrGroupId];
        System.debug(user);
        return user;
    }
    
    @AuraEnabled 
    public static string updateGroup(Id recordId,Id userId) {
        
        try {
            String recordIdStr = recordId;
            String userIdStr = userId;
            
            notifyCurrentUser(recordIdStr, userIdStr,'กรุณากดรับงานภายใน 24 ชม. มิฉะนั้นงานจะถูกนำกลับอัตโนมัติ');
            
            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='LMS Business Hours'];
            Datetime now = Datetime.now();
            Integer slaHours = 9;
            Datetime targetTime = BusinessHours.addGmt(bh.Id, now, slaHours* 60 * 60 * 1000L);
            if(recordIdStr.startsWith('00Q')){
                Lead lead = new Lead(id=recordId);
                System.debug('Lead');
                lead.OwnerId = userId;
                lead.Status = 'มอบหมายงานให้ตัวแทนแล้ว';
                lead.SLA__c = targetTime;
                update lead;
            }else if(recordIdStr.startsWith('006')){
                Opportunity opp = new Opportunity(id=recordId);
                opp.OwnerId = userId;
                update opp;    
            }
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }
    
    @future(callout=true) 
    public static void notifyCurrentUser(String leadId, String userId, String message)
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Url.getOrgDomainUrl().toExternalForm()
            + '/services/data/v46.0/actions/standard/customNotificationAction');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        CustomNotificationActionInput input = new CustomNotificationActionInput();
        input.customNotifTypeId = '0MLq0000000CaihGAC';
        input.recipientIds = new List<String>{userId};
        input.title = 'มีงานเข้าใหม่';
        input.body = message;
        input.targetId = leadId;

        // CustomNotificationActionInput input2 = new CustomNotificationActionInput();
        // input2.customNotifTypeId = '0MLq0000000CaihGAC';
        // input2.recipientIds = new List<String>{'005q00000069jFLAAY'};
        // input2.title = 'Test Data Operation Completed2';
        // input2.body = message;
        // input2.targetId = '001q000001HJ289AAD'; 

        CustomNotificationAction action = new CustomNotificationAction();
        action.inputs = new List<CustomNotificationActionInput>{input};
        req.setBody(JSON.serialize(action));
        HttpResponse res = h.send(req);
        System.debug(res.getBody());
    }
    
    public class CustomNotificationAction
    {
        public List<CustomNotificationActionInput> inputs { get; set; }
    }

    public class CustomNotificationActionInput
    {
        public String customNotifTypeId { get; set; }
        public List<String> recipientIds { get; set; }
        public String title { get; set; }
        public String body { get; set; }
        public String targetId { get; set; }
    }
}