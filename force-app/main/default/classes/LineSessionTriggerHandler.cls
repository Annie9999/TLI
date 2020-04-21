public with sharing class LineSessionTriggerHandler {
    public static void handleBeforeInsert(List<ChatSession__c> line) {
        try {
            for(ChatSession__c l : line) {
                Case newCase = new Case();
                RecordType recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CC_Service_Request' LIMIT 1]; // CC เรื่องที่ให้บริการ
                newCase.RecordTypeId = recId.Id; 
                newCase.Status = 'งานใหม่';
                newCase.Origin = 'LINE';
                newCase.TLI_Division__c = 'CC สายงานไทยประกันชีวิตแคร์เซ็นเตอร์';
                newCase.TLI_Subdivision__c = 'CC ศูนย์บริการลูกค้า';
                newCase.Subject = '[LINE] ติดต่อสอบถาม';
                insert newCase;
                System.debug('Auto Case : caseId='+newCase.Id);

                l.Service_Request__c = newCase.Id;
            }

        } catch (Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }

    public static void handleAfterUpdate(List<ChatSession__c> line, Map<Id,ChatSession__c> oldLine) {
        try {
            Set<Id> caseIdSet = new Set<Id>();
            List<Case> caseOwnerUpdateList = new List<Case>();
            for(ChatSession__c l : line) {
                caseIdSet.add(l.Service_Request__c);
            }
            
            Map<Id,Case> serviceReqList = new Map<Id,Case>([SELECT Id,OwnerId FROM Case WHERE Id in: caseIdSet]);
            
           	for(ChatSession__c l : line) {
                Case c = serviceReqList.get(l.Service_Request__c);
                if(c!=null){
                   c.OwnerId = l.OwnerId;
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