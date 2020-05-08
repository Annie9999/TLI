public with sharing class TestNotificationCtrl {
    public static void notifyCurrentUser(String message)
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
        input.recipientIds = new List<String>{'00Gq0000003jE4o'};
        input.title = 'Test Data Operation Completed';
        input.body = message;
        input.targetId = '001q000001HJ289AAD';

        CustomNotificationActionInput input2 = new CustomNotificationActionInput();
        input2.customNotifTypeId = '0MLq0000000CaihGAC';
        input2.recipientIds = new List<String>{'005q00000069jFLAAY'};
        input2.title = 'Test Data Operation Completed2';
        input2.body = message;
        input2.targetId = '001q000001HJ289AAD'; 

        CustomNotificationAction action = new CustomNotificationAction();
        action.inputs = new List<CustomNotificationActionInput>{input,input2};
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