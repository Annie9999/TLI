({
	doInit: function(component, event, helper) {
		// Create the action
		var action = component.get("c.getLead");
		var recordId = component.get("v.recordId");
		// Add callback behavior for when response is received
		action.setParams({
            leadId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // var storeResponse = response.getReturnValue().mapDependent;
                var leadRecord = response.getReturnValue();
                component.set("v.leadRecord", leadRecord);
                // component.set("v.accountName", opptyRecord.Account.FirstName +' '+ opptyRecord.Account.LastName);
                // console.log('StageName: '+opptyRecord.StageName);
                // console.log('Approval_Status__c: '+opptyRecord.Approval_Status__c);



                // if(opptyRecord.StageName == 'Closed Won' && opptyRecord.Approval_Status__c != 'QC ปฏิเสธ'){
                //     component.set("v.status", true);

                // }else{
                //     component.set("v.status", false);

                // }

               // component.set("v.stageName", opptyRecord.StageName);
              //  component.set("v.approvalStatus", opptyRecord.Approval_Status__c);


           
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