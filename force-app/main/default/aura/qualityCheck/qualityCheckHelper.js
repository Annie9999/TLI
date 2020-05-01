({

 

    verify : function(component, event, helper) {
        console.log('#####-saveQuestion-#####');

        var caseId = component.get('v.recordId');
        var questList = component.get('v.questions');
        var valid_info = component.get("v.valid_information");
    
        var ansList = [];
        questList.forEach((element, index, array) => {
            // console.log('element',element);
            ansList.push(element.tmpAnswer);
        } );
        
        console.log('questList: ',JSON.parse(JSON.stringify(questList)));
        console.log('valid_information: '+valid_info.Answer__c);
        console.log('ansList: '+ansList);


        var action = component.get('c.saveQuestion');
        action.setParams({
            caseId: caseId,
            valid_info: valid_info.Answer__c,
            quesList: questList,
            ansList: ansList
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === 'SUCCESS'){
                var returnVal = response.getReturnValue();
                var valid_information = returnVal.shift();
                var questionAnswer = returnVal;
                // console.log(returnVal.shift());
                // console.log(returnVal);
                component.set('v.isAnswered', true);
                component.set('v.information_question', valid_information);
                component.set('v.questionAnswer', questionAnswer);
                console.log('success');
            }
            else{
                console.log(response.getError());
                console.log('Failed');
            }
        });

        $A.enqueueAction(action);
    },
    update : function(component, event, helper){
        console.log('#####-updateQuestionAnswer-#####');


        var questionAnswer = component.get('v.questionAnswer');
        var informationQuestion = component.get('v.information_question');
        questionAnswer.push(informationQuestion);

        var action = component.get("c.updateQuestionAnswer");
        //console.log('questionAnswer'+ Object.values(questionAnswer));
        console.log('questionAnswer: ',JSON.parse(JSON.stringify(questionAnswer)));

        action.setParams({
            questionAnswer: questionAnswer
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //$A.get('e.force:refreshView').fire();

                //เอา informationQuestion ออกจากท้าย array (คำถามข้อมูลถูกต้องมั้ย)
                questionAnswer.pop();
                console.log(component.get('v.questionAnswer'));
                // component.set('v.questionAnswer', [])
            }
            else{
                console.log('failed');
            }
        });
        $A.enqueueAction(action);

    },
    accept : function(component, event, helper){
        var toastEvent = $A.get("e.force:showToast");
        var isAnswered = component.get('v.isAnswered');
        console.log('isAnswered'+isAnswered);
        if(!isAnswered){
            //Inset QC Answer Form
            this.verify(component, event, helper);
            //Inset QC Answer Form
        }
        else{
            //Update QC Answer Form
            console.log('else');
            this.update(component, event, helper);
            //Update QC Answer Form
        }


        console.log('#####-sendToNB-#####');
        var caseId = component.get('v.recordId');
        console.log('caseId: '+caseId);

        var action = component.get('c.sendToNB');
        action.setParams({
            caseId: caseId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                toastEvent.setParams({
                    "title": "สำเร็จ",
                    "message": "ส่งเคสให้ NB เรียบร้อยแล้ว",
                    "type": "success"
                });
                toastEvent.fire();
                console.log('good');
                helper.refreshFocusedTab(component);
            }
            else{
                toastEvent.setParams({
                    "title": "Error",
                    "message": "เกิดข้อผิดพลาด",
                    "type": "error"
                });
                toastEvent.fire();
                console.log('bad');
                
            }
        });

        $A.enqueueAction(action);
        //Update Opty Status

    },
    toConsult : function(component, event, helper){

        var toastEvent = $A.get("e.force:showToast");
        var isAnswered = component.get('v.isAnswered');
        console.log("isAnswered"+isAnswered);
        if(!isAnswered){
            //Inset QC Answer Form
            helper.verify(component, event, helper);
            //Inset QC Answer Form
        }
        else{
            //Update QC Answer Form
            helper.update(component, event, helper);
            //Update QC Answer Form
        }


        console.log('#####-sendToConsult-#####');
        var caseId = component.get('v.recordId');
        console.log('caseId: '+caseId);

        var action = component.get('c.sendToConsult');
        action.setParams({
            caseId: caseId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                toastEvent.setParams({
                    "title": "สำเร็จ",
                    "message": "ส่งเคสให้ UW เรียบร้อยแล้ว",
                    "type": "success"
                });
                toastEvent.fire();
                console.log('good');
                helper.refreshFocusedTab(component);
            }
            else{
                toastEvent.setParams({
                    "title": "Error",
                    "message": "เกิดข้อผิดพลาด",
                    "type": "error"
                });
                toastEvent.fire();
                console.log('bad');
            }
        });

        $A.enqueueAction(action);
        //Update Opty Status
        
    },
    reject : function(component, event, helper){

        var toastEvent = $A.get("e.force:showToast");
        var isAnswered = component.get('v.isAnswered');
        console.log('reject isanswered'+isAnswered);

        if(!isAnswered){
            //Inset QC Answer Form
            helper.verify(component, event, helper);
            //Inset QC Answer Form
        }
        else{
            //Update QC Answer Form
            helper.update(component, event, helper);
            //Update QC Answer Form
        }

        console.log('#####-reject-#####');
        //Update lead Status
        var caseId = component.get('v.recordId');
        var description = component.get('v.rejectDescription');
        console.log('caseId: ' +caseId);
        console.log('description: ' +description);

        var action = component.get('c.rejectQC');
        action.setParams({
            caseId: caseId,
            description: description
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('good');

                toastEvent.setParams({
                    "title": "สำเร็จ",
                    "message": "ปฏิเสธ QC เรียบร้อยแล้ว",
                    "type": "success"
                });
                toastEvent.fire();
                helper.refreshFocusedTab(component);
            }
            else{
                console.log('bad');
                toastEvent.setParams({
                    "title": "Error",
                    "message": "เกิดข้อผิดพลาด",
                    "type": "error"
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
        //Update Opty Status

    },
    refreshFocusedTab : function(component) {
        var workspaceAPI = component.find("workspace");
        // console.log('TestTAE');
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                      tabId: focusedTabId,
                      includeAllSubtabs: true
             });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})