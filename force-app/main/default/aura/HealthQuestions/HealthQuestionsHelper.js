({
    getQuestion : function(component, event,helper) {
        console.log('-----getQuestion-----');
        
        var recordId =  component.get("v.recordId");
        var questType =  component.get("v.questType");
        console.log('recordId: '+recordId);
        
        var action = component.get("c.getQuestion");
        action.setParams({ 
            "leadId": recordId,
            "questType": questType
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();
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
        
        var recordId =  component.get("v.recordId");
        var quesList =  component.get('v.questions'); 
        console.log('recordId: '+recordId);
        
        
        var ansList = [];
        quesList.forEach((element, index, array) => {
            // console.log('element',element);
            ansList.push(element.TmpAnswser);
        } );
            
           /* console.log('recordId: '+recordId);
            console.log('QA: ',JSON.parse(JSON.stringify(quesList)));
            console.log('ansList: ',JSON.parse(JSON.stringify(ansList)));*/
            
            var action = component.get("c.saveQuestionAnswers");
            action.setParams({ 
            "leadId": recordId,
            "quesList": quesList,
            "ansList": ansList
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var currentStep = parseInt(component.get('v.currentStep'));
                currentStep = currentStep+1;
                component.set('v.currentStep',currentStep+'' );
                
            }
        });
        $A.enqueueAction(action)  
        
        
        
    },
    updateQA : function(component, event, helper) {
        
        console.log('-----updateQA-----');
        
        var questionAnswer =  component.get("v.questionAnswer");
        console.log('Q&A: ',JSON.parse(JSON.stringify(questionAnswer)));
        
        var action = component.get("c.updateQuestionAnswer");
        action.setParams({ 
            "questionAnswer": questionAnswer
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var currentStep = parseInt(component.get('v.currentStep'));
                currentStep = currentStep+1;
                component.set('v.currentStep',currentStep+'' );
                
            }
        });
        $A.enqueueAction(action)  
        
        
    },
    
    
    
})