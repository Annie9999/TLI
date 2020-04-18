({
    verify : function(component, event, helper) {
        var questList = component.get('v.questions');
        console.log(questList);
        var valid_info = component.get("v.valid_information");
        console.log(valid_info.Answer__c);
        var id = component.get('v.recordId');
        // var recordId =  component.get("v.recordId");
        var ansList = [];
        questList.forEach((element, index, array) => {
            // console.log('element',element);
            ansList.push(element.tmpAnswer);
        } );
        
        var action = component.get('c.saveQuestion');
        action.setParams({
            recordId: id,
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
        var questionAnswer = component.get('v.questionAnswer');
        var informationQuestion = component.get('v.information_question');
        questionAnswer.push(informationQuestion);
        var action = component.get("c.updateQuestionAnswer");
        console.log('questionAnswer'+ Object.values(questionAnswer));
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

        //Update Opty Status
        var recordId = component.get('v.recordId');

        console.log(recordId);

        var action = component.get('c.sendToNB');
        action.setParams({
            recordId: recordId
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
        
        //Update Opty Status
        var recordId = component.get('v.recordId');
        
        console.log(recordId);

        var action = component.get('c.sendToConsult');
        action.setParams({
            recordId: recordId
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

        //Update Opty Status
        var recordId = component.get('v.recordId');
        var description = component.get('v.rejectDescription');
        console.log(recordId);
        console.log(description);

        var action = component.get('c.rejectQC');
        action.setParams({
            recordId: recordId,
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

    }
})