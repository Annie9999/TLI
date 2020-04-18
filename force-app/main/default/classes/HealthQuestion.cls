public class HealthQuestion {
    
    
    public class qaWrapper {
        @AuraEnabled
        public List<Answer_Form__c> listQA {get; set;}
        @AuraEnabled
        public List<Question__c> listQues {get; set;}
        
      /* @AuraEnabled
        public  List<String> Quest    {get; set;}
        @AuraEnabled
        public  List<String> Answer    {get; set;}

        @AuraEnabled
        public  MAP<String,String> QA    {get; set;}*/
     
        
        @AuraEnabled
        public boolean ansId {get; set;}

       
    }



   /* public class wrapperQA {
        /*@AuraEnabled
        public List<Answer_Form__c> ansList {get; set;}
        @AuraEnabled
        public List<Question__c> quesList {get; set;}
         @AuraEnabled
        public Map<List<String>, List<String>> mapList {get; set;}
        

    
        @AuraEnabled
        public List<String> ques{get; set;}
        @AuraEnabled
        public List<String> ans{get; set;}
       

    }*/

    
    
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



     //   qaWrapper qaReturn = new qaWrapper();
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


        
      /*  List<Application_Form__c> appFormList =[SELECT Id , Opportunity__c FROM Application_Form__c WHERE Opportunity__c =: recordId];
        if(appFormList.isEmpty()){

            Application_Form__c appForm = new Application_Form__c();
            appForm.Opportunity__c = recordId;
            insert appForm;

            Opportunity oppty = [SELECT Id, (select Id,Opportunity__c from Application_Forms__r WHERE Id=:appForm.Id ) FROM Opportunity WHERE Id =:appForm.Opportunity__c  limit 1];
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

            
        }else{

            

        }*/

       


     
   
    }

    @AuraEnabled
    public static void updateQuestionAnswer( List<Answer_Form__c> questionAnswer)  {
        
        system.debug('questionAnswer: ' +questionAnswer);
        update questionAnswer;

        
    }















    /* @AuraEnabled
    public static void saveQuestionAnswers(String recordId,  List<Answer_Form__c> quesList, List<String> ansList)  {
        system.debug('recordId: ' +recordId);
        system.debug('quesList: ' +quesList);
        system.debug('ansList: ' +ansList);
        
       Opportunity oppty = [SELECT Id, (select Id,Opportunity__c from Application_Forms__r ) FROM Opportunity WHERE Id =:recordId limit 1];
 
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
        


    }*/
    
   




    //--------------Test----------------



    
   /* @AuraEnabled
    public static wrapperQA getQuest(String opptyId, String questGroup)  {
        system.debug('opptyId: ' +opptyId);
        system.debug('questGroup: ' +questGroup);

        wrapperQA qaReturn = new wrapperQA();
        List<String> strQues = new List<String>();
        List<String> strAns = new List<String>();

        List<Answer_Form__c> qa =[SELECT Id, Name, Question__c, Answer__c, Opportunity__c, Application_Form__c FROM Answer_Form__c WHERE Opportunity__c =: opptyId ];
        if(!qa.isEmpty()){ 
            for(Answer_Form__c a: qa){
                strAns.add(a.Answer__c);
                

                
            }
            qaReturn.ans =strAns;
                system.debug('qaReturn: ' +qaReturn);
                return qaReturn;

        }
        List<Question__c> ques = [SELECT Id,Name,Question_Group__c,Question_Order__c,Question__c  FROM Question__c   WHERE Question_Group__c=:questGroup ORDER BY Question_Order__c ASC];
        for(Question__c q: ques){
            strQues.add(q.Question__c);
           
        }
        qaReturn.ques =strQues;
        system.debug('qaReturn: ' +qaReturn);
        return qaReturn;
       

      
    
        
    }*/



  /*  @AuraEnabled
    public static wrapperQA getQuest(String opptyId,String questGroup ){
        system.debug('get_opptyId: ' +opptyId);
        system.debug('get_questGroup: ' +questGroup);



        List<String> strQues = new List<String>();


        wrapperQA qaReturn = new wrapperQA();
        List<Answer_Form__c> qa =[SELECT Id, Name, Question__c, Answer__c, Opportunity__c, Application_Form__c FROM Answer_Form__c WHERE Opportunity__c =: opptyId ];
        if(!qa.isEmpty()){

            /*List<Question__c> ques = [SELECT Id,Name,Question_Group__c,Question_Order__c,Question__c  FROM Question__c   WHERE Question_Group__c=:questGroup ORDER BY Question_Order__c ASC];
            for(Question__c q: ques){
                
                strQues.add(q.Question__c) ;
               

            }
            qaReturn.ques= strQues ;
            return qaReturn;
        }
      
       /* Map<List<String>,List<String>> mapQA = new Map<List<String>,List<String>>();
        List<String> strQues = new List<String>();
        List<String> strAns = new List<String>();

        List<Answer_Form__c> qa =[SELECT Id, Name, Question__c, Answer__c, Opportunity__c, Application_Form__c FROM Answer_Form__c WHERE Opportunity__c =: opptyId ];
        if(!qa.isEmpty()){
            for(Answer_Form__c a: qa){

                List<Question__c> ques = [SELECT Id,Name,Question_Group__c,Question_Order__c,Question__c  FROM Question__c   WHERE Question_Group__c=:questGroup ORDER BY Question_Order__c ASC];
                for(Question__c q: ques){
                    strQues.add(q.Question__c);
                }
                strAns.add(a.Answer__c);
                mapQA.put(strQues, strAns);

            }
        }
        

        system.debug('mapQA: ' +mapQA);


       
        

    }*/


  /*  @AuraEnabled
    public static void saveQA(String opptyId,List<Question__c> quesList, List<String> ansList,String questGroup){
        system.debug('save_opptyId: ' +opptyId);
        system.debug('save_quesList: ' +quesList);
        system.debug('save_ansList: ' +ansList);
        system.debug('save_questGroup: ' +questGroup);

        Opportunity oppty = [SELECT Id, (select Id,Opportunity__c from Application_Forms__r ) FROM Opportunity WHERE Id =:opptyId  and  Opportunity.Question_Group__c =: questGroup limit 1];
        List<Answer_Form__c> qaList = new List<Answer_Form__c>();
        for(integer i=0; i< quesList.size(); i++){
            Answer_Form__c stmAns = new Answer_Form__c();
            stmAns.Question__c = quesList[i].Question__c;
            stmAns.Answer__c = ansList[i];    
            stmAns.Opportunity__c = oppty.Id;
            stmAns.Application_Form__c = oppty.Application_Forms__r.get(0).Id;
            qaList.add(stmAns);
        }
        system.debug('save_qaList: ' +qaList); 
        insert qaList;
    }


    @AuraEnabled
    public static List<Answer_Form__c> updateQA(String opptyId){
        system.debug('update_pptyId: ' +opptyId);

        List<Answer_Form__c> qaList =[SELECT Id, Name, Question__c, Answer__c, Opportunity__c, Application_Form__c FROM Answer_Form__c WHERE Opportunity__c =: opptyId ];
        
        return qaList;

    }*/

    
}