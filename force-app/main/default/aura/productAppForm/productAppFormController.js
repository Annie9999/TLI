/* eslint-disable no-unused-expressions */
({
	doInit: function(component, event, helper) {
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
            var storeResponse = response.getReturnValue().mapDependent;
            var opptyRecord = response.getReturnValue().opptyObj;
            var gender = opptyRecord.gender__c === 'ชาย' ? 'M':'F';
            var accRecord = response.getReturnValue().accObj;
            var listOfkeys = []; // for store all map keys (controller picklist values)
            var ControllerField = []; // for store controller picklist value to set on lightning:select. 
            
            console.log('gender : ' + gender);
            if (state === "SUCCESS") {
                component.set("v.opptyRecord", opptyRecord);
                component.set("v.accRecord", accRecord);
                component.set("v.depnedentFieldMap", storeResponse);
                component.set("v.genderValue", gender);
                component.set("v.amount", '0.00');
                component.set("v.saveSuccess", false);

                for (var singlekey in storeResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for lightning:select
                if (listOfkeys !== undefined && listOfkeys.length > 0) {
                    ControllerField.push('--- None ---');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                // set the ControllerField variable values to country(controller picklist field)
                component.set("v.listControllingValues", ControllerField);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },

    onControllerFieldChange: function(component, event, helper) {  
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
        component.set("v.saveSuccess", false);

        console.log('controllerValueKey '+controllerValueKey);
        
        if (controllerValueKey !== '--- None ---') {
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
        helper.functionSendQuotation(component, event, helper);
    },

    TypePrice : function(component, event, helper) {
        component.set("v.saveSuccess", false);
        helper.functionTypePrice(component, event, helper);
    },
    onNext : function(component, event, helper) {
        console.log(component.get('v.objDetail.productgroup__c'));
        console.log(component.get('v.objDetail.Sub_productgroup__c'));
        console.log(component.get('v.accRecord.PersonBirthdate'));
        console.log(component.get('v.genderValue'));
        console.log(component.get('v.paymentmethidValue'));
        helper.functionNextPage(component, event, helper);
    },

    onClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    onSaveOpp : function(component, event, helper) {

        component.set("v.Spinner", true);
        helper.functionSave(component, event, helper);
        window.setTimeout(
            $A.getCallback(function() {
                $A.get('e.force:refreshView').fire();
                component.set("v.Spinner", false);
            }), 10000
        );
    },

    refreshFocusedTab: function (component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        console.log('>>>>> refreshFocusedTab');
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.parentTabId;
            workspaceAPI.refreshTab({
                tabId: focusedTabId,
                includeAllSubtabs: true
            });
        }).catch(function (error) {
            console.log(error);
        });
    },
})