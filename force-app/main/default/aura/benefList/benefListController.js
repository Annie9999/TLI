({
    addBenef : function(component, event, helper) {
        var benefList = component.get("v.benefList");

        if(benefList.length >= 4){
            return;
        }

        benefList.push({
            'Salutation': '',
            'FirstName': '',
            'LastName': '',
            'Birthdate': '',
            'Relationship__c': '',
            'Percentage_Beneficiary__c': ''
    
        });
        console.log(benefList.length);
        component.set("v.benefList", benefList);
        console.log(component.get("v.benefList"));

    },
    removeBenef : function(component, event, helper){
        var benefList = component.get("v.benefList");
        var index = event.getSource().get("v.name");
        console.log(event.getSource().get("v.name"));

        benefList.splice(index, 1);

        for(var [index, benef] of benefList.entries()){
            benef.Priority__c = index+1; 
        }

        component.set("v.benefList", benefList);
        console.log(benefList);
    },
    verify : function(component, event, helper){
        //var contact = component.get('v.benefList');

        var totalPercent = 0;
        var percentFields = [];
        var validForm = component.find('benefForm').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();

            if(inputCmp.get('v.name') === 'percent_benefit'){
                inputCmp.setCustomValidity('');
                inputCmp.reportValidity();
                totalPercent += parseInt(inputCmp.get('v.value'));
                percentFields.push(inputCmp);
            }

            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        // If we pass error checking, do some real work
        //console.log('value '+ percentFields[0].get('v.value'));
        //console.log('percent '+ totalPercent);
        if(validForm){

            if(totalPercent != 100){
                for(var field of percentFields){
                    field.setCustomValidity('กรุณาใส่สัดส่วนให้ถูกต้อง');
                    field.reportValidity();
                    console.log("Not correct");
                }
            }
            if(totalPercent === 100){
                for(var field of percentFields){
                    field.setCustomValidity('');
                    field.reportValidity();
                    console.log("correct");
                }

                var benefList = component.get("v.benefList");
                var oppId = component.get("v.recordId");

                console.log(JSON.stringify(benefList));

                var action = component.get("c.createBeneficiary");
                action.setParams({
                    benefList: JSON.stringify(benefList),
                    oppId: oppId
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        //console.log(response.getRetunValue());
                        console.log(state);
                        var currentStep = parseInt(component.get('v.currentStep'));
                        currentStep = currentStep+1;
                        component.set('v.currentStep',currentStep+'' );
                    }
                    else{
                        console.log(response.getError());
                    }
                });
                $A.enqueueAction(action);
                //helper.functionNextPage(component, event, helper);

            }

        }
    },
    handleAddressOption : function (component, event, helper){
        var option = component.get('v.selectedOption');
        
        switch(option){
            case 'option1':

                console.log("Handling ที่อยู่ปัจจุบัน");
                component.set('v.selectedOption', option);
                break;
            case 'option2':

                console.log("Handling สถานที่ทำงาน");
                component.set('v.selectedOption', option);
                break;
            case 'option3':

                console.log("Handling ที่อยู่ตามทะเบียนบ้าน");
                component.set('v.selectedOption', option);
                break;
            case 'option4':

                console.log("Handling ที่อยู่ตามผู้ชำระเบี้ย");
                component.set('v.selectedOption', option);
                break;
        }
    },
    
    onNext : function(component, event, helper) {
        
        helper.functionNextPage(component, event, helper);
    }
})