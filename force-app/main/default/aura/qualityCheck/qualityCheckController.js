({
    doInit : function(component, event, helper) {
        var id = component.get('v.recordId');
        console.log(id);

        var action = component.get('c.getCase');
        // var action = component.get('c.getOpp');
        action.setParams({
            caseId: id
            // oppId: id
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('OpptyId'+returnVal.Opportunity__c);
                component.set('v.opptyId', returnVal.Opportunity__c);
                component.set('v.info', returnVal);

                var q_type = component.get('v.questType');
                var opptyId = component.get('v.opptyId');
                console.log('Opty2: '+opptyId);

                action = component.get('c.getQuestions');
                action.setParams({
                    type: q_type,
                    oppId: opptyId
                });

                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === 'SUCCESS'){
                        var returnVal = response.getReturnValue();
                        console.log(returnVal);

                        if(returnVal.isAnswered == true){
                            console.log("isAnswered"+returnVal.isAnswered);
                            console.log('ListAns'+returnVal.listAnsForm);
                            var information = returnVal.listAnsForm.shift();
                            component.set('v.isAnswered', returnVal.isAnswered);
                            component.set('v.information_question', information);
                            component.set('v.questionAnswer', returnVal.listAnsForm);
                        }
                        else{

                            component.set('v.isAnswered', returnVal.isAnswered);
                            component.set('v.questions', returnVal.listQuestion);
                        }
                    }
                    else{

                        console.log("Get questions failed");
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                console.log("Failed");
            }
        });

        
        $A.enqueueAction(action);
    },
    openModal : function(component, event, helper){


        var validForm = component.find('checkForm').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();

            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if(validForm){
            var modal = component.find('summaryModal');
            var backdrop = component.find('summaryBackdrop');
            var isAnswered = component.get('v.isAnswered');
            
            if(isAnswered){
                var questList = component.get('v.questionAnswer');
                component.set('v.questionAnswer', questList);
            }
            else{
                var questList = component.get('v.questions');
                component.set('v.questions', questList);
            }

            var topic = event.getSource().get('v.name');
            console.log(component.get('v.questionAnswer'));
            switch (topic) {
                case 'nb':
                    component.set('v.submitMode', topic);
                    component.set('v.modalHeader', 'ยืนยันส่งเคสให้ NB');
                    break;

                case 'uw':
                    component.set('v.submitMode', topic);
                    component.set('v.modalHeader', 'ยืนยันส่งเคสให้ UW');
                    break;

                case 'reject':
                    component.set('v.submitMode', topic);
                    component.set('v.modalHeader', 'ยืนยันปฏิเสธ QC');
                    break;
            
                default:
                    break;
            }

            console.log(event.getSource().get('v.name'));
            $A.util.addClass(modal, 'slds-fade-in-open');
            $A.util.addClass(backdrop, 'slds-backdrop--open'); 
        }
    },
    closeModal : function(component, event, helper){
        
        var modal = component.find('summaryModal');
        var backdrop = component.find('summaryBackdrop');

        $A.util.removeClass(modal, 'slds-fade-in-open');
        $A.util.removeClass(backdrop, 'slds-backdrop--open'); 
    },
    submit : function(component, event, helper){
        var modal = component.find('summaryModal');
        var backdrop = component.find('summaryBackdrop');
        var mode = component.get('v.submitMode');
        console.log('mode'+mode);

        switch (mode) {
            case 'nb':
                helper.accept(component, event, helper);
                $A.util.removeClass(modal, 'slds-fade-in-open');
                $A.util.removeClass(backdrop, 'slds-backdrop--open'); 
                break;
            case 'uw':
                
                helper.toConsult(component, event, helper);
                $A.util.removeClass(modal, 'slds-fade-in-open');
                $A.util.removeClass(backdrop, 'slds-backdrop--open'); 
                break;
            case 'reject':
                

                helper.reject(component, event, helper);
                $A.util.removeClass(modal, 'slds-fade-in-open');
                $A.util.removeClass(backdrop, 'slds-backdrop--open'); 
                break;
        
            default:
                break;
        }
    }
})