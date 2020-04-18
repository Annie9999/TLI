public with sharing class MessagingSessionTriggerHandler {
    public static void MessagingSessionTrigger(String sessionId) {
        // Auto Service Request
        Case newCase = new Case();
        RecordType recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CC_Service_Request' LIMIT 1]; // CC เรื่องที่ให้บริการ
        newCase.RecordTypeId = recId.Id; 
        newCase.Status = 'งานใหม่';
        newCase.Origin = 'Live Chat';
        newCase.TLI_Division__c = 'CC สายงานไทยประกันชีวิตแคร์เซ็นเตอร์';
        newCase.TLI_Subdivision__c = 'CC ศูนย์บริการลูกค้า';
        newCase.Subject = 'Messenger Chat';
        insert newCase;
        // System.debug('caseId='+newCase.Id);

        List<MessagingSession> message = [SELECT Id, caseId, OwnerId, LastModifiedById FROM MessagingSession WHERE Id = :sessionId];
        for(MessagingSession m : message) {
            m.caseId = newCase.Id;
            newCase.OwnerId = m.OwnerId;
        }
        update message;
        update newCase;

    }

    public static void UpdateServiceRequestOwner(String sessionId) {
        MessagingSession message = [SELECT Id, caseId, OwnerId, LastModifiedById FROM MessagingSession WHERE Id = :sessionId];
        Case serviceReq = [SELECT OwnerId FROM Case WHERE Id = : message.caseId];
        serviceReq.OwnerId = message.OwnerId;
        update serviceReq;

    }
}