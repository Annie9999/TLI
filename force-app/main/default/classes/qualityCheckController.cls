public with sharing class qualityCheckController {

    public class returnWrapper{
        @AuraEnabled
        public List<QC_Answer_Form__c> listAnsForm {get; set;}
        @AuraEnabled
        public List<Question__c> listQuestion {get; set;}
        @AuraEnabled
        public boolean isAnswered {get; set;}
    }

    @AuraEnabled
    public static Case getCase(Id caseId){
        System.debug('#####-getCase-#####');

        System.debug('caseId: '+caseId);
        Case target = [SELECT Id, Status,Lead__c,Lead__r.Name ,Lead__r.Agee__c,Lead__r.Email,Lead__r.Phone,Lead__r.Street__c,Lead__r.City__c,Lead__r.State__c ,Lead__r.PostalCode__c ,Lead__r.Country__c ,Lead__r.AnnualRevenue  FROM Case WHERE Id = :caseId LIMIT 1];
        System.debug('target: '+ target.Status);
       
        return target;
    }

  
    
    @AuraEnabled
    public static returnWrapper getQuestions(String quesType, String leadId){
        System.debug('#####-getQuestions-#####');

        System.debug('leadId: '+leadId);
        System.debug('quesType: '+quesType);

        returnWrapper rw = new returnWrapper();
        List<QC_Answer_Form__c> checker = [SELECT Id, Name, Question__c, Answer__c, Lead__c, Application_Form__c FROM QC_Answer_Form__c WHERE Lead__c = :leadId];
        System.debug('checker: '+checker.size());
        if(!checker.isEmpty()){
            rw.listAnsForm = checker;
            rw.isAnswered = true;
            System.debug('Not empty'+rw.listAnsForm);
            return rw;
        }else{

            List<Question__c> questions = [SELECT Id,Name,Question_Group__c,Question_Order__c,Question__c FROM Question__c WHERE Question_Group__c = :quesType AND Question_Order__c >= 1 ORDER BY Question_Order__c ASC];
            rw.listQuestion = questions;
            rw.isAnswered = false;
            System.debug('Empty'+rw.listQuestion);
            return rw;
        }
      
    }

    @AuraEnabled
    public static QC_Answer_Form__c[] saveQuestion(String caseId, String valid_info, List<QC_Answer_Form__c> quesList, List<String> ansList){
        system.debug('#####-saveQuestion-#####');

        System.debug('caseId: ' +caseId);
        System.debug('valid_info: ' +valid_info);
        System.debug('quesList: ' +quesList);
        System.debug('ansList: ' +ansList);

        List<QC_Answer_Form__c> answerList = new List<QC_Answer_Form__c>();

      
        Case qcCase = [SELECT Id,Lead__c, Status FROM Case WHERE Id = :caseId  limit 1];
        Application_Form__c appForm = new Application_Form__c();
        appForm.Lead__c = qcCase.Lead__c;
        insert appForm;

        Lead leads = [SELECT Id, (select Id,Lead__c from Application_Forms__r WHERE Id=:appForm.Id ) FROM Lead WHERE Id =:appForm.Lead__c  limit 1];
        system.debug('leads: ' +leads.Id);
        system.debug('appForm: ' +leads.Application_Forms__r.get(0).Id);

   
        Question__c valid_question = [SELECT Id,Name,Question_Group__c,Question_Order__c,Question__c FROM Question__c WHERE Question_Group__c = 'QC' AND Question_Order__c = 0 LIMIT 1];
        QC_Answer_Form__c valid_form = new QC_Answer_Form__c();
        valid_form.Question__c = valid_question.Question__c;
        valid_form.Answer__c = valid_info;
        valid_form.Lead__c = leads.Id;
        valid_form.Application_Form__c = leads.Application_Forms__r.get(0).Id;
        answerList.add(valid_form);

        for(Integer i = 0;i < quesList.size();i++){
            QC_Answer_Form__c newForm = new QC_Answer_Form__c();
            newForm.Question__c = quesList[i].Question__c;
            newForm.Answer__c = ansList[i];   
            newForm.Lead__c = leads.Id;
            newForm.Application_Form__c = leads.Application_Forms__r.get(0).Id;
            answerList.add(newForm); 
        }
        system.debug('answerList: ' +answerList); 

        qcCase.Status = 'ดำเนินการเรียบร้อย';
        update qcCase;
        insert answerList;
       return answerList;




       /* Case qcCase = [SELECT Id,Lead__c, Status FROM Case WHERE Id = :caseId  limit 1];
        qcCase.Status = 'ดำเนินการเรียบร้อย';
        Id leadId = qcCase.Lead__c;
        System.debug('leadId: '+leadId);*/
        /*Question__c valid_question = [SELECT Id,Name,Question_Group__c,Question_Order__c,Question__c FROM Question__c WHERE Question_Group__c = 'QC' AND Question_Order__c = 0 LIMIT 1];
        System.debug(valid_info);
        System.debug(valid_question);
        System.debug(caseId);
        List<QC_Answer_Form__c> answerList = new List<QC_Answer_Form__c>();
        Case qcCase = [SELECT Opportunity__c, Status FROM Case WHERE Id = :caseId  limit 1];
        Id oppty = qcCase.Opportunity__c;
        System.debug('Opty'+oppty);
        qcCase.Status = 'ดำเนินการเรียบร้อย';
        QC_Answer_Form__c valid_form = new QC_Answer_Form__c();
        valid_form.Question__c = valid_question.Question__c;
        valid_form.Answer__c = valid_info;
        valid_form.Opportunity__c = oppty;
        answerList.add(valid_form);
        for(Integer i = 0;i < quesList.size();i++){
            QC_Answer_Form__c newForm = new QC_Answer_Form__c();
            newForm.Question__c = quesList[i].Question__c;
            newForm.Answer__c = ansList[i];   
            newForm.Opportunity__c = oppty;
            answerList.add(newForm);
        }
        system.debug('answerList: ' +answerList); 
       update qcCase;
       insert answerList;*/
    }
    
    @AuraEnabled
    public static void updateQuestionAnswer(List<QC_Answer_Form__c> questionAnswer)  {
        
        system.debug('questionAnswer: ' +questionAnswer);
        update questionAnswer;

        
    }

    @AuraEnabled
    public static void sendToNB(String caseId){
        system.debug('#####-sendToNB-#####');
        System.debug('caseId: ' + caseId);

        Lead target = [SELECT Id, Account__c FROM Lead WHERE Id IN (SELECT Lead__c FROM Case WHERE Id = :caseId) limit 1];
        target.Sub_Status__c = 'ส่งคำขอเพื่ออนุมัติกรมธรรม์';
        update target;
        updateCaseStatus(target.Id);
        /*target.StageName = 'อยู่ในช่วงการพิจารณา';  */

        String subject = 'อนุมัติขั้นตอนการออกกรมธรรม์';
        String description = '';
        String priority = 'Medium';
        Group nbQ = [SELECT Id, Name FROM Group WHERE Name='DM New Business Queue'];
        Utility.createCase(subject, description, priority,target.Id, nbQ.Id, 'DM Process');

    
       /*Opportunity target = [SELECT Id, StageName, AccountId FROM Opportunity WHERE Id IN (SELECT Opportunity__c FROM Case WHERE Id = :recordId)];
        target.StageName = 'อยู่ในช่วงการพิจารณา';
        target.Approval_Status__c = 'ส่งคำขอเพื่ออนุมัติกรมธรรม์';
        update target;
        updateCaseStatus(target.Id);*/
      /*  String subject = 'อนุมัติขั้นตอนการออกกรมธรรม์';
        String description = '';
        String priority = 'Medium';
        Group nbQ = [SELECT Id, Name FROM Group WHERE Name='DM New Business Queue'];
        Utility.createCase(subject, description, priority, target.AccountId, target.Id, nbQ.Id, 'DM Process');*/
       
    }

    @AuraEnabled
    public static void rejectQC(String caseId, String description){
        system.debug('#####-rejectQC-#####');
        System.debug('caseId: ' + caseId);
        System.debug('description: ' + description);

        Lead target = [SELECT Id, Account__c FROM Lead WHERE Id IN (SELECT Lead__c FROM Case WHERE Id = :caseId) limit 1];
        target.Sub_Status__c = 'QC ปฏิเสธ';
        target.Description  = description;
        update target;
        updateCaseStatus(target.Id);
       /* target.StageName = 'อยู่ในช่วงการพิจารณา'; */






       /* Opportunity target = [SELECT Id, StageName, AccountId FROM Opportunity WHERE Id IN (SELECT Opportunity__c FROM Case WHERE Id = :recordId)];
        System.debug(target.StageName);
        target.StageName = 'อยู่ในช่วงการพิจารณา';
        target.Description = description;
        target.Approval_Status__c = 'QC ปฏิเสธ';
        System.debug(target);
        update target;
        updateCaseStatus(target.Id);*/
    }

    @AuraEnabled
    public static void sendToConsult(String caseId){
        system.debug('#####-sendToConsult-#####');
        System.debug('caseId: ' + caseId);

        Lead target = [SELECT Id, Account__c FROM Lead WHERE Id IN (SELECT Lead__c FROM Case WHERE Id = :caseId) limit 1];
        target.Sub_Status__c = 'ส่งเรื่องถึง UW';
        update target;
        updateCaseStatus(target.Id);
       /* target.StageName = 'อยู่ในช่วงการพิจารณา'; */


        String subject = 'Underwriter ทำการประเมินผลสุขภาพของผู้มุ่งหวัง';
        String description = 'กรุณาประเมินว่าผู้มุ่งหวังมีสิทธิ์รับความคุ้มครองจากผลิตภัณฑ์นั้นๆได้หรือไม่';
        String type = 'Medium';
        Group uwQ = [SELECT Id, Name FROM Group WHERE Name='UW Queue'];
        Utility.createCase(subject, description, type, target.Id, uwQ.Id, 'DM Process');





       /* Opportunity target = [SELECT Id, StageName, AccountId FROM Opportunity WHERE Id IN (SELECT Opportunity__c FROM Case WHERE Id = :recordId)];
        target.StageName = 'อยู่ในช่วงการพิจารณา';
        target.Approval_Status__c = 'ส่งเรื่องถึง UW';
        System.debug('NB '+target);
        update target;
        updateCaseStatus(target.Id);
        String subject = 'Underwriter ทำการประเมินผลสุขภาพของผู้มุ่งหวัง';
        String description = 'กรุณาประเมินว่าผู้มุ่งหวังมีสิทธิ์รับความคุ้มครองจากผลิตภัณฑ์นั้นๆได้หรือไม่';
        String type = 'Medium';    
        Group uwQ = [SELECT Id, Name FROM Group WHERE Name='UW Queue'];
        Utility.createCase(subject, description, type, target.AccountId, target.Id, uwQ.Id, 'DM Process');*/
    }


    @AuraEnabled
    public static void updateCaseStatus(String leadId){
        System.debug('leadId: ' + leadId);

        Case qcCase = [SELECT Lead__c, Status FROM Case WHERE Lead__c = :leadId  limit 1];
        qcCase.Status = 'ดำเนินการเรียบร้อย';
       // System.debug('Case leadId: ' + qcCase.Lead__c);
       // System.debug('Case status: ' + qcCase.Status);
        update qcCase;
    }

    
}