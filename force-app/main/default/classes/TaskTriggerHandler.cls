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


    public static void handleAfterInsert(List<Task> newTask) {
        List<Task> logACallList = new List<Task>();
        Set<Id> leadIdLogCall = new Set<Id>(); 
        Set<Lead> leadRemindTask = new Set<Lead>(); 
        for (Task t : newTask) {
            if(t.TaskSubtype == 'Call' && t.Subject=='ติดต่อไม่สำเร็จ'){
                // logACallList.add(t);
                if(String.ValueOf(t.WhoId).startsWith('00Q')){
                    leadIdLogCall.add(t.WhoId);
                }
            } 
        }
        List<Lead> leadListLogAcall = [SELECT Id ,OwnerId,
                                    (SELECT id,Subject,WhoId FROM Tasks WHERE Subject='ติดต่อไม่สำเร็จ' AND TaskSubtype ='Call' ORDER BY CreatedDate DESC )
                                    FROM Lead 
                                    WHERE Id IN:leadIdLogCall AND RecordTypeId =: Schema.SObjectType.Lead.getRecordTypeInfosByName().get('สนใจทำประกันผ่านตัวแทน').getRecordTypeId() ];
        System.debug('leadListLogAcall : '+leadListLogAcall);
        /* Log A Call */
        for(Lead l : leadListLogAcall){
            if(l.Tasks.size() > 0){
                if(l.Tasks.size() > 2){
                    logACallList.add(l.Tasks.get(0));
                }else{
                    leadRemindTask.add(l);
                }
            }
        }
        System.debug('logACallList :'+logACallList);
        System.debug('leadRemindTask :'+leadRemindTask);
        /* create event platform */
        if(logACallList.size() > 0){

            List<LogACallEvent__e> logAcallEvtList = new List<LogACallEvent__e>();
            for(Task t : logACallList){
                LogACallEvent__e logAcallevt = new LogACallEvent__e();
                logAcallevt.WhoId__c = t.WhoId;
                logAcallevt.TaskId__c = t.Id;
                logAcallEvtList.add(logAcallevt);
            }
            System.debug('logAcallEvtList : '+logAcallEvtList);
            if (logAcallEvtList.size() > 0) {
                List<Database.SaveResult> results = EventBus.publish(logAcallEvtList);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        for (Database.Error error : result.getErrors()) {
                            System.debug('Error returned: ' + error.getStatusCode() +' - '+ error.getMessage());
                        }
                    }
                }
            }
        }
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='LMS Business Hours'];
        Datetime now = Datetime.now();
        Integer slaHours = 2;

        /* create new task for remind */
        if(leadRemindTask.size() > 0){
            // Datetime targetTime = BusinessHours.addGmt(bh.Id, now, slaHours* 60 * 60 * 1000L);
            List<Task> newTaskforRemind = new List<Task>();
            for(Lead l : leadRemindTask){
                Time myTime = Time.newInstance(17, 0, 0, 0);
                DateTime dt = DateTime.newInstance(Date.today(), myTime);

                Task t = new Task();
                t.IsReminderSet = true;
                t.ReminderDateTime = dt;
                t.ActivityDate = Date.today();
                if(String.ValueOf(l.OwnerId).startsWith('00G')){
                    t.OwnerId = UserInfo.getUserId();
                }else{
                    t.OwnerId = l.OwnerId;
                }
                t.Subject = 'โทรหาลูกค้า';
                t.WhoId = l.Id;
                newTaskforRemind.add(t);
            }
            System.debug('newTaskforRemind :'+newTaskforRemind);
            insert newTaskforRemind;
           
        }
    }
}