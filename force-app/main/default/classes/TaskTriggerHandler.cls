public with sharing class TaskTriggerHandler {
    public static void handleBeforeInsert(List<Task> newTask) {
        Set<Id> whatIdSet = new Set<Id>();
        Set<Id> taskIdSet = new Set<Id>();
        for (Task t : newTask) {
            whatIdSet.add(t.WhatId);
            taskIdSet.add(t.Id);   
        }

        Map<Id,Case> caseList = new Map<Id,Case>([SELECT Id FROM Case WHERE (Id = :whatIdSet OR AccountId = :whatIdSet) ORDER BY CreatedDate DESC LIMIT 1]);
        
        for (Task t : newTask) {
            Case c = caseList.get(t.WhatId);

            //Create IVR Survey
            IVR_Survey__c ivr = new IVR_Survey__c();
            ivr.Name = 'IVR Survey';
            if(c!=null) {
                ivr.Link_to_case__c = c.Id;
            } 
            ivr.Voice_reference__c = 'https://demo.voice.com/docs/voice.xml';
            insert ivr;

            //Create IVR Survey Score
            IVR_Survey_Score__c ivrScore = new IVR_Survey_Score__c();
            ivrScore.Name = 'IVR Survey Score';
            ivrScore.IVR_Survey__c = ivr.Id;
            ivrScore.Question_Number__c = 1;
            ivrScore.Question_Text__c = 'How statified are you with our service, on a scale of 1-5?';
            ivrScore.Score__c = 5;
            ivrScore.Score_Text__c = '...';
            insert ivrScore;      

            t.IVR_Survey__c = ivr.Id;
        }    

    }
}