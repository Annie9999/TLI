public with sharing class TaskTriggerHandler {
    public static void TaskTrigger(String whatId, String taskId) {
        //Create a recode in IVR Survey when log a call was create        
        List<Case> caseId = [SELECT Id FROM Case WHERE (Id = :whatId OR AccountId = :whatId) ORDER BY CreatedDate DESC LIMIT 1];
        IVR_Survey__c ivr = new IVR_Survey__c();
        ivr.Name = 'IVR Survey';
        if(!caseId.isEmpty()){
            ivr.Link_to_case__c = caseId[0].Id;
        } 
        ivr.Voice_reference__c = 'https://demo.voice.com/docs/voice.xml';
        insert ivr;
        String ivrId = ivr.Id;
        // System.debug('ivrId='+ivrId);

        //Create a recode in IVR Survey Score
        IVR_Survey_Score__c ivrScore = new IVR_Survey_Score__c();
        ivrScore.Name = 'IVR Survey Score';
        ivrScore.IVR_Survey__c = ivrId;
        ivrScore.Question_Number__c = 1;
        ivrScore.Question_Text__c = 'How statified are you with our service, on a scale of 1-5?';
        ivrScore.Score__c = 5;
        ivrScore.Score_Text__c = '...';
        insert ivrScore;       

        //Update Task
        List<Task> task = [SELECT Id, IVR_Survey__c FROM Task WHERE Id = :taskId];
        for (Task t : task) {
            t.IVR_Survey__c = ivrId;
        }    
        update task;
    }
}