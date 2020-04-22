public with sharing class MessagingSessionTriggerHandler {
    public static void handleBeforeInsert(List<MessagingSession> message) {
        try {
            List<Case> newCaseList = new List<Case>();
            RecordType recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CC_Service_Request' LIMIT 1]; // CC เรื่องที่ให้บริการ
            for(MessagingSession m : message) {
                Case newCase = new Case();              
                newCase.RecordTypeId = recId.Id; 
                newCase.Status = 'งานใหม่';
                newCase.Origin = 'Facebook Messenger';
                newCase.TLI_Division__c = 'CC สายงานไทยประกันชีวิตแคร์เซ็นเตอร์';
                newCase.TLI_Subdivision__c = 'CC ศูนย์บริการลูกค้า';
                newCase.Subject = '[Facebook Messenger] ติดต่อสอบถาม';
                newCaseList.add(newCase);
            } 

            if(newCaseList.size() > 0) {
                insert newCaseList;
            }

            List<String> caseIds = new List<String>();
            for (Case c : newCaseList) {
                caseIds.add(c.Id);
            }

            Integer i = 0;
            for(MessagingSession m : message) {
                m.caseId = caseIds[i];
                i++;
            }
           
        } catch (Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
        
    }

    public static void handleAfterUpdate(List<MessagingSession> message, Map<Id,MessagingSession> oldMessage) {
        try {
            Set<Id> caseIdSet = new Set<Id>();
            List<Case> caseOwnerUpdateList = new List<Case>();
            for(MessagingSession m : message) {
                caseIdSet.add(m.caseId);
            }
            
            Map<Id,Case> serviceReqList = new Map<Id,Case>([SELECT Id,OwnerId FROM Case WHERE Id in: caseIdSet]);
            
           	for(MessagingSession m : message) {
                Case c = serviceReqList.get(m.caseId);
                if(c!=null){
                   c.OwnerId = m.OwnerId;
                   caseOwnerUpdateList.add(c);
                }
            }
            
            if(caseOwnerUpdateList.size() > 0){
                update caseOwnerUpdateList;
            }
            
        } catch (Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
        
    }
}