({
    getQuestion : function(component, event,helper) {
        console.log('-----getQuestion-----');
        var recordId =  component.get("v.recordId");
        var questType =  component.get("v.questType");

        var action = component.get("c.getQuestion");
        action.setParams({ 
            "recordId": recordId,
            "questType": questType
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();

               /* console.log('Return Questions: ',JSON.parse(JSON.stringify(returnVal)));
                component.set("v.questions",returnVal.listQues);
                component.set("v.ansId",returnVal.ansId);*/

                

                if(returnVal.ansId == true){
                
                    console.log('Return QA: ',JSON.parse(JSON.stringify(returnVal)));
                    component.set("v.questionAnswer",returnVal.listQA);
                    component.set("v.ansId",returnVal.ansId);


                }else{
    
                    console.log('Return Questions: ',JSON.parse(JSON.stringify(returnVal)));
                    component.set("v.questions",returnVal.listQues);
                    component.set("v.ansId",returnVal.ansId);
                    

                    

                }
                
            }
        });
        $A.enqueueAction(action)  
    },
      saveQA : function(component, event, helper) {

        console.log('-----saveQA-----');
        var msg ='Are you sure ?';
        //if (confirm(msg)) {
            
              var recordId =  component.get("v.recordId");
              var quesList =  component.get('v.questions');  
              var ansList = [];
                    quesList.forEach((element, index, array) => {
                        // console.log('element',element);
                        ansList.push(element.TmpAnswser);
                    } );
                        
                        console.log('recordId: '+recordId);
                        console.log('QA: ',JSON.parse(JSON.stringify(quesList)));
                        console.log('ansList: ',JSON.parse(JSON.stringify(ansList)));
                        var action = component.get("c.saveQuestionAnswers");
                        action.setParams({ 
                            "recordId": recordId,
                            "quesList": quesList,
                            "ansList": ansList
                    	});
            
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                               /* var returnVal = response.getReturnValue();
                                if(returnVal.ansId == true){
                                    component.set("v.ansId",returnVal.ansId);
                                    component.set("v.questionAnswer",returnVal.listQA);
                                    console.log('Return QA: ',JSON.parse(JSON.stringify(returnVal.listQA)));
                                }*/
                                
                                //$A.get('e.force:refreshView').fire();
                                //helper.functionNextPage(component, event, helper);
                                var currentStep = parseInt(component.get('v.currentStep'));
                                currentStep = currentStep+1;
                                component.set('v.currentStep',currentStep+'' );

                            }
                        });
                        $A.enqueueAction(action)  
                        
            	
        //}
        
    },
    updateQA : function(component, event, helper) {

        console.log('-----updateQA-----');
        var msg ='Are you sure ?';
       // if (confirm(msg)) {
            
            var questionAnswer =  component.get("v.questionAnswer");
            console.log('Q&A: ',JSON.parse(JSON.stringify(questionAnswer)));
            
            var action = component.get("c.updateQuestionAnswer");
            action.setParams({ 
                "questionAnswer": questionAnswer
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //$A.get('e.force:refreshView').fire();
                   // helper.functionNextPage(component, event, helper);
                    var currentStep = parseInt(component.get('v.currentStep'));
                    currentStep = currentStep+1;
                    component.set('v.currentStep',currentStep+'' );

                }
            });
            $A.enqueueAction(action)  
            
        //}
        
    },

   /* functionNextPage: function(component, event, helper) {
        console.log('Next');
        var currentStep = parseInt(component.get('v.currentStep'));
        if(currentStep < 4){
            currentStep = currentStep+1;
        }
        if(currentStep == 4){
            setTimeout(() => {
                currentStep = currentStep+1;
                component.set('v.currentStep',currentStep+'' );
            }, 2000);
        }
        console.log('currentStep : '+currentStep);
        component.set('v.currentStep',currentStep+'' );
    },*/
    
})