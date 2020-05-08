({
    uwApprove: function(component, event, helper) {
        var action = component.get("c.uwApprove");
        var recordId = component.get("v.recordId");

        action.setParams({ 'recordId' : recordId });

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var resultAcccount = response.getReturnValue();

				console.log('Result : '+ JSON.stringify(resultAcccount));
			}
			else {
				alert('Unable to fetch data from server');
			}
		});

       $A.enqueueAction(action);
    },
    uwReject: function(component, event, helper) {
        var action = component.get("c.uwReject");       
        var recordId = component.get("v.recordId");

        action.setParams({ 'recordId' : recordId });

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var resultAcccount = response.getReturnValue();

				console.log('Result : '+ JSON.stringify(resultAcccount));
			}
			else {
				alert('Unable to fetch data from server');
			}
		});

       $A.enqueueAction(action);
    },
    nbApprove: function(component, event, helper) {
        var action = component.get("c.nbApprove");
        var recordId = component.get("v.recordId");

        action.setParams({ 'recordId' : recordId });

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var resultAcccount = response.getReturnValue();

				console.log('Result : '+ JSON.stringify(resultAcccount));
			}
			else {
				alert('Unable to fetch data from server');
			}
		});

       $A.enqueueAction(action);
    },
    nbReject: function(component, event, helper) {
        var action = component.get("c.nbReject");
        var recordId = component.get("v.recordId");

        action.setParams({ 'recordId' : recordId });

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var resultAcccount = response.getReturnValue();

				console.log('Result : '+ JSON.stringify(resultAcccount));
			}
			else {
				alert('Unable to fetch data from server');
			}
		});

       $A.enqueueAction(action);
    },

})