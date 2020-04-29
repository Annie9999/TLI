public class HealthQuestion {
    
    
    public class qaWrapper {
        @AuraEnabled
        public List<Answer_Form__c> listQA {get; set;}
        @AuraEnabled
        public List<Question__c> listQues {get; set;}
        
        @AuraEnabled
        public boolean ansId {get; set;}
        
        
    }
    
    
    @AuraEnabled
    public static qaWrapper getQuestion(String leadId, String questType)  {
        system.debug('leadId: ' +leadId);
        system.debug('questType: ' +questType);
        
        qaWrapper qaReturn = new qaWrapper();
        List<Answer_Form__c> qa =[SELECT Id, Name, Question__c, Answer__c, Lead__c, Application_Form__c FROM Answer_Form__c WHERE Lead__c =: leadId ];
        if(!qa.isEmpty()){ 
            qaReturn.listQA =qa;
            qaReturn.ansId = true;
            system.debug('Q&A: ' +qaReturn);
            return qaReturn;
            
        }else{
            List<Question__c> ques = [SELECT Id,Name,Question_Group__c,Question_Order__c,Question__c  FROM Question__c   WHERE Question_Group__c=:questType ORDER BY Question_Order__c ASC];
            qaReturn.listQues =ques;
            qaReturn.ansId =false;
            system.debug('Question: ' +qaReturn);
            return qaReturn;
            
        }
        
    }
    
    
    @AuraEnabled
    public static void saveQuestionAnswers(String leadId,  List<Answer_Form__c> quesList, List<String> ansList)  {
        system.debug('leadId: ' +leadId);
        system.debug('quesList: ' +quesList);
        system.debug('ansList: ' +ansList);
        
        Application_Form__c appForm = new Application_Form__c();
        appForm.Lead__c = leadId;
        insert appForm;
        
        
        Lead leads = [SELECT Id, (select Id,Lead__c from Application_Forms__r WHERE Id=:appForm.Id ) FROM Lead WHERE Id =:appForm.Lead__c  limit 1];
        system.debug('leads: ' +leads.Id);
        system.debug('appForm: ' +leads.Application_Forms__r.get(0).Id);
        
        List<Answer_Form__c> qaList = new List<Answer_Form__c>();
        for(integer i=0; i< quesList.size(); i++){
            Answer_Form__c stmAns = new Answer_Form__c();
            stmAns.Question__c = quesList[i].Question__c;
            stmAns.Answer__c = ansList[i];    
            stmAns.Lead__c = leads.Id;
            stmAns.Application_Form__c = leads.Application_Forms__r.get(0).Id;
            qaList.add(stmAns);
        }
        system.debug('qaList: ' +qaList); 
        insert qaList;
    }
    
    @AuraEnabled
    public static void updateQuestionAnswer( List<Answer_Form__c> questionAnswer)  {
        
        system.debug('questionAnswer: ' +questionAnswer);
        update questionAnswer;
        
        
    }
    
    
    
    
    
    
    
    
    
    //Opportunity
    
    /*public class qaWrapper {
@AuraEnabled
public List<Answer_Form__c> listQA {get; set;}
@AuraEnabled
public List<Question__c> listQues {get; set;}
@AuraEnabled
public boolean ansId {get; set;}


}


@AuraEnabled
public static qaWrapper getQuestion(String recordId, String questType)  {
system.debug('recordId: ' +recordId);
system.debug('questType: ' +questType);

qaWrapper qaReturn = new qaWrapper();
List<Answer_Form__c> qa =[SELECT Id, Name, Question__c, Answer__c, Opportunity__c, Application_Form__c FROM Answer_Form__c WHERE Opportunity__c =: recordId ];
if(!qa.isEmpty()){ 
qaReturn.listQA =qa;
qaReturn.ansId = true;
system.debug('Q&A: ' +qaReturn);
return qaReturn;

}else{
List<Question__c> ques = [SELECT Id,Name,Question_Group__c,Question_Order__c,Question__c  FROM Question__c   WHERE Question_Group__c=:questType ORDER BY Question_Order__c ASC];
qaReturn.listQues =ques;
qaReturn.ansId =false;
system.debug('Question: ' +qaReturn);
return qaReturn;

}

}




@AuraEnabled
public static void saveQuestionAnswers(String recordId,  List<Answer_Form__c> quesList, List<String> ansList)  {
system.debug('recordId: ' +recordId);
system.debug('quesList: ' +quesList);
system.debug('ansList: ' +ansList);

Application_Form__c appForm = new Application_Form__c();
appForm.Opportunity__c = recordId;
insert appForm;



Opportunity oppty = [SELECT Id, (select Id,Opportunity__c from Application_Forms__r WHERE Id=:appForm.Id ) FROM Opportunity WHERE Id =:appForm.Opportunity__c  limit 1];
system.debug('oppty: ' +oppty.Id);
system.debug('appForm: ' +oppty.Application_Forms__r.get(0).Id);

List<Answer_Form__c> qaList = new List<Answer_Form__c>();
for(integer i=0; i< quesList.size(); i++){
Answer_Form__c stmAns = new Answer_Form__c();
stmAns.Question__c = quesList[i].Question__c;
stmAns.Answer__c = ansList[i];    
stmAns.Opportunity__c = oppty.Id;
stmAns.Application_Form__c = oppty.Application_Forms__r.get(0).Id;
qaList.add(stmAns);
}
system.debug('qaList: ' +qaList); 
insert qaList;








}

@AuraEnabled
public static void updateQuestionAnswer( List<Answer_Form__c> questionAnswer)  {

system.debug('questionAnswer: ' +questionAnswer);
update questionAnswer;


}*/
    
    
    
    
    
}