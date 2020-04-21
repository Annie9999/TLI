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
        System.debug(caseId);
        Case target = [SELECT Id, Account.Name, Account.Age__c, Account.Annual_Income__c, Account.PersonEmail, Account.Phone, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry, Opportunity__c,Status FROM Case WHERE Id = :caseId LIMIT 1];
        System.debug('target: '+ target.Status);
        return target;
    }

    @AuraEnabled
    public static Opportunity getOpp(Id oppId){
        System.debug(oppId);
        Opportunity target = [SELECT Id, Account.Name, Account.Age__c, Account.Annual_Income__c, Account.PersonEmail, Account.Phone, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry FROM Opportunity WHERE Id = :oppId LIMIT 1];
        return target;
    }
    
    @AuraEnabled
    public static returnWrapper getQuestions(String type, String oppId){
        System.debug(oppId);
        returnWrapper rw = new returnWrapper();

        List<QC_Answer_Form__c> checker =[SELECT Id, Name, Question__c, Answer__c, Opportunity__c, Application_Form__c FROM QC_Answer_Form__c WHERE Opportunity__c = :oppId];
        if(!checker.isEmpty()){
            //System.debug('Not empty'+rw.listAnsForm);
            rw.listAnsForm = checker;
            rw.isAnswered = true;
            System.debug('Not empty'+rw.listAnsForm);
            return rw;
        }
        else{
            List<Question__c> questions = [SELECT Id,Name,Question_Group__c,Question_Order__c,Question__c FROM Question__c WHERE Question_Group__c = :type AND Question_Order__c >= 1 ORDER BY Question_Order__c ASC];
            System.debug('Empty'+rw.listQuestion);
            rw.listQuestion = questions;
            rw.isAnswered = false;
            return rw;
        }
    }

    @AuraEnabled
    public static QC_Answer_Form__c[] saveQuestion(String recordId, String valid_info, List<QC_Answer_Form__c> quesList, List<String> ansList){
        System.debug(quesList);
        System.debug(ansList);
        Question__c valid_question = [SELECT Id,Name,Question_Group__c,Question_Order__c,Question__c FROM Question__c WHERE Question_Group__c = 'QC' AND Question_Order__c = 0 LIMIT 1];

        System.debug(valid_info);
        System.debug(valid_question);
        System.debug(recordId);
        List<QC_Answer_Form__c> answerList = new List<QC_Answer_Form__c>();
        // Id oppty = [SELECT Opportunity__c FROM Case WHERE Id = :recordId  limit 1].Opportunity__c;
        Case qcCase = [SELECT Opportunity__c, Status FROM Case WHERE Id = :recordId  limit 1];

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
        insert answerList;

        return answerList;
    }
    
    @AuraEnabled
    public static void updateQuestionAnswer(List<QC_Answer_Form__c> questionAnswer)  {
        
        system.debug('questionAnswer: ' +questionAnswer);
        update questionAnswer;

        
    }

    @AuraEnabled
    public static void sendToNB(String recordId){

        Opportunity target = [SELECT Id, StageName, AccountId FROM Opportunity WHERE Id IN (SELECT Opportunity__c FROM Case WHERE Id = :recordId)];

        target.StageName = 'อยู่ในช่วงการพิจารณา';
        target.Approval_Status__c = 'ส่งคำขอเพื่ออนุมัติกรมธรรม์';
        update target;

        updateCaseStatus(target.Id);

       /* Case qcCase = [SELECT Opportunity__c, Status FROM Case WHERE Opportunity__c = :target.Id  limit 1];
        qcCase.Status = 'ดำเนินการเรียบร้อย';
        System.debug('oppty Id: ' + qcCase.Opportunity__c);
        System.debug('Case status: ' + qcCase.Status);
        update qcCase;*/
        //System.debug(Schema.SObjectType.Case.getRecordTypeInfosByName().get('DM Process').getRecordTypeId());

        String subject = 'อนุมัติขั้นตอนการออกกรมธรรม์';
        String description = '';
        String priority = 'Medium';
        Group nbQ = [SELECT Id, Name FROM Group WHERE Name='DM New Business Queue'];
        Utility.createCase(subject, description, priority, target.AccountId, target.Id, nbQ.Id, 'DM Process');
        // Case newCase = new Case();
        // newCase.Subject = 'อนุมัติขั้นตอนการออกกรมธรรม์';
        // newCase.Type = 'Internal Process';
        // newCase.Description = '';
        // newCase.Priority = 'Medium';
        // newCase.OwnerId = nbQ.Id;
        // newCase.Opportunity__c = target.Id;
        // newCase.AccountId = target.AccountId;

        // System.debug(newCase);
        // upsert newCase;
    }

    @AuraEnabled
    public static void rejectQC(String recordId, String description){
        Opportunity target = [SELECT Id, StageName, AccountId FROM Opportunity WHERE Id IN (SELECT Opportunity__c FROM Case WHERE Id = :recordId)];
        System.debug(target.StageName);

        target.StageName = 'อยู่ในช่วงการพิจารณา';
        target.Description = description;
        target.Approval_Status__c = 'QC ปฏิเสธ';
        System.debug(target);
        update target;

        updateCaseStatus(target.Id);


        /*Case qcCase = [SELECT Opportunity__c, Status FROM Case WHERE Opportunity__c = :target.Id  limit 1];
        qcCase.Status = 'ดำเนินการเรียบร้อย';
        System.debug('oppty Id: ' + qcCase.Opportunity__c);
        System.debug('Case status: ' + qcCase.Status);
        update qcCase;*/

       

        


    }

    @AuraEnabled
    public static void sendToConsult(String recordId){
        Opportunity target = [SELECT Id, StageName, AccountId FROM Opportunity WHERE Id IN (SELECT Opportunity__c FROM Case WHERE Id = :recordId)];

        target.StageName = 'อยู่ในช่วงการพิจารณา';
        target.Approval_Status__c = 'ส่งเรื่องถึง UW';
        System.debug('NB '+target);
        update target;

        updateCaseStatus(target.Id);


        /*Case qcCase = [SELECT Opportunity__c, Status FROM Case WHERE Opportunity__c = :target.Id  limit 1];
        qcCase.Status = 'ดำเนินการเรียบร้อย';
        System.debug('oppty Id: ' + qcCase.Opportunity__c);
        System.debug('Case status: ' + qcCase.Status);
        update qcCase;*/

        String subject = 'Underwriter ทำการประเมินผลสุขภาพของผู้มุ่งหวัง';
        String description = 'กรุณาประเมินว่าผู้มุ่งหวังมีสิทธิ์รับความคุ้มครองจากผลิตภัณฑ์นั้นๆได้หรือไม่';
        String type = 'Medium';
        
        Group uwQ = [SELECT Id, Name FROM Group WHERE Name='UW Queue'];
        Utility.createCase(subject, description, type, target.AccountId, target.Id, uwQ.Id, 'DM Process');

        
        // Case newCase = new Case();
        // newCase.Subject = 'Underwriter ทำการประเมินผลสุขภาพของผู้มุ่งหวัง';
        // newCase.Type = 'Internal Process';
        // newCase.Description = 'กรุณาประเมินว่าผู้มุ่งหวังมีสิทธิ์รับความคุ้มครองจากผลิตภัณฑ์นั้นๆได้หรือไม่';
        // newCase.Priority = 'Medium';
        // newCase.OwnerId = uwQ.Id;
        // newCase.Opportunity__c = target.Id;
        // newCase.AccountId = target.AccountId;

        // System.debug(newCase);
        // upsert newCase;
    }


    @AuraEnabled
    public static void updateCaseStatus(String opptyId){

        System.debug('oppty Id: ' + opptyId);
        Case qcCase = [SELECT Opportunity__c, Status FROM Case WHERE Opportunity__c = :opptyId  limit 1];
        qcCase.Status = 'ดำเนินการเรียบร้อย';
        System.debug('Case oppty: ' + qcCase.Opportunity__c);
        System.debug('Case status: ' + qcCase.Status);
        update qcCase;
    }

    
}