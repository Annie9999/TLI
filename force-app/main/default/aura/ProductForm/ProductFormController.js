({

	doInit: function(component, event, helper) {
		var status = component.get("v.status");
        console.log('status: '+status);


		// Create the action
		var action = component.get("c.getDetail");
        var recordId = component.get("v.recordId");
        console.log('action ');
        console.log('recordId '+recordId);
		// Add callback behavior for when response is received
		action.setParams({
            oppId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue().mapDependent;
                var opptyRecord = response.getReturnValue().opptyObj;
                var accRecord = response.getReturnValue().accObj;
                var subName = opptyRecord.Sub_productgroup__c;
                component.set("v.opptyRecord", opptyRecord);
                component.set("v.accRecord", accRecord);
                component.set("v.depnedentFieldMap", storeResponse);
                
                
                if(opptyRecord.Amount!=null){
                    component.set("v.price", opptyRecord.Amount);
                }
                else{
                    component.set("v.price", '0.00');
                }
                
                // console.log(opptyRecord.Amount);
                if(accRecord.Sex__pc=='ชาย'){
                    component.set("v.genderValue", 'M');
                }
                else{
                    component.set("v.genderValue", 'F');
                }

                if(opptyRecord.Payment_Mode__c!=null){
                    if(opptyRecord.Payment_Mode__c=='รายเดือน'){
                        component.set("v.paymentmethidValue", '1_month');
                    }
                    else if(opptyRecord.Payment_Mode__c=='ราย 3 เดือน'){
                        component.set("v.paymentmethidValue", '3_months');
                    }
                    else if(opptyRecord.Payment_Mode__c=='ราย 6 เดือน'){
                        component.set("v.paymentmethidValue", '6_months');
                    }
                    else if(opptyRecord.Payment_Mode__c=='รายปี'){
                        component.set("v.paymentmethidValue", 'year');
                    }
                }
                else{
                    component.set("v.paymentmethidValue", '1_month');
                }

                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in storeResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for lightning:select
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push('--- None ---');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                // set the ControllerField variable values to country(controller picklist field)
                component.set("v.listControllingValues", ControllerField);
                // component.find("a_opt").set("v.value", "ประกันชีวิต");

                if(opptyRecord.productgroup__c!=null){
                    setTimeout(() => {
                        component.set("v.objDetail.productgroup__c", opptyRecord.productgroup__c);
                        // component.set("v.objDetail.Sub_productgroup__c", "ก้าวแรก");
                        helper.functionAddValuePicklist(component, helper,subName);
                        helper.functionTypePrice(component, event, helper);
                    }, 200);
                    // component.set("v.objDetail.productgroup__c", opptyRecord.productgroup__c);
                }
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },

    onControllerFieldChange: function(component, event, helper) {  
        console.log('onControllerFieldChange');
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        console.log('controllerValueKey '+controllerValueKey);
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },

    fnSendQuotation: function(component, event, helper) {
        helper.functionSaveAndSendEmail(component, event, helper);
        // helper.functionSendQuotation(component, event, helper);
    },

    TypePrice : function(component, event, helper) {
        helper.functionTypePrice(component, event, helper);
    },
    onNext : function(component, event, helper) {
        console.log(component.get('v.objDetail.productgroup__c'));
        console.log(component.get('v.objDetail.Sub_productgroup__c'));
        console.log(component.get('v.accRecord.PersonBirthdate'));
        console.log(component.get('v.genderValue'));
        console.log('====='+component.get('v.paymentmethidValue'));
        console.log('====='+component.get('v.price'));
        helper.functionSave(component, event, helper);
    },
})