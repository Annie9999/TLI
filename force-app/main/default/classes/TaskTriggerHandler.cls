public with sharing class TaskTriggerHandler {
    public static void handleBeforeInsert(List<Task> newTask) {
        Set<Id> whatIds = new Set<Id>();
        Set<Id> taskIds = new Set<Id>();
        for (Task t : newTask) {
            whatIds.add(t.WhatId);
            taskIds.add(t.Id);   
        }

        List<IVR_Survey__c> ivrList = new List<IVR_Survey__c>();
        List<IVR_Survey_Score__c> ivrScoreList = new List<IVR_Survey_Score__c>();
        Map<Id,Case> caseList = new Map<Id,Case>(
            [SELECT Id FROM Case WHERE (Id = :whatIds OR AccountId = :whatIds) ORDER BY CreatedDate DESC LIMIT 1]);
        
        for (Task t : newTask) {
            Case c = caseList.get(t.WhatId);
            //Create IVR Survey
            IVR_Survey__c ivr = new IVR_Survey__c();
            ivr.Name = 'IVR Survey';
            if(c!=null) {
                ivr.Link_to_case__c = c.Id;
            } 
            ivr.Voice_reference__c = 'https://demo.voice.com/docs/voice.xml';
            ivrList.add(ivr);          
        }

        if(ivrList.size() > 0) {
            insert ivrList;
        }

        List<String> ivrIds = new List<String>();
        for (IVR_Survey__c ivr : ivrList) {
            ivrIds.add(ivr.Id);
        }

        Integer i = 0;
        for (Task t : newTask) {
            //Create IVR Survey Score
            IVR_Survey_Score__c ivrScore = new IVR_Survey_Score__c();
            ivrScore.Name = 'IVR Survey Score';
            ivrScore.IVR_Survey__c = ivrIds[i];
            ivrScore.Question_Number__c = 1;
            ivrScore.Question_Text__c = 'How statified are you with our service, on a scale of 1-5?';
            ivrScore.Score__c = 5;
            ivrScore.Score_Text__c = '...';
            ivrScoreList.add(ivrScore);    

            t.IVR_Survey__c = ivrIds[i];
            i++;
        }

        if(ivrScoreList.size() > 0) {
            insert ivrScoreList;
        }
        
    }
}