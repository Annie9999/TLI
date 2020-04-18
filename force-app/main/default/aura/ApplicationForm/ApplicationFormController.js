({
	doInit: function(component, event, helper) {
		// Create the action
		var action = component.get("c.getOpportunity");
		var recordId = component.get("v.recordId");
		// Add callback behavior for when response is received
		action.setParams({
            oppId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // var storeResponse = response.getReturnValue().mapDependent;
                var opptyRecord = response.getReturnValue();
                component.set("v.opptyRecord", opptyRecord);
                component.set("v.accountName", opptyRecord.Account.FirstName +' '+ opptyRecord.Account.LastName);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },
    onNext : function(component, event, helper) {
		console.log(component.get('v.planValue'));
        console.log(component.get('v.genderValue'));
        console.log(component.get('v.birthdateValue'));
        console.log(component.get('v.paymentmethidValue'));
        helper.functionNextPage(component, event, helper);
    },
    onStep : function(component, event, helper) {
        // console.log(component.get('v.currentStep'));
        console.log(event.getSource().get("v.value"));
        helper.functionClickPage(component, event, helper);
    },
})