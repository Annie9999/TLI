({
	getInsuredInfo: function (component, event, helper) {
		// Create the action
		var action = component.get("c.getInsuredInfo");
		var leadId = component.get("v.recordId");

		action.setParams({ 'leadId' : leadId });

		// Add callback behavior for when response is received
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();

				component.set("v.ld", result);

				if(result.City__c != undefined){
					var billing = result.City__c.split(",");
					//var billing = JSON.stringify(result.BillingCity).split(",");
					if(billing.length > 0){
						component.set("v.billingSubDistrict", billing[0]);
						component.set("v.billingDistrict", billing[1]);
					}
				}
				
				if(result.City != undefined){
					var shipping = result.City.split(",");
					//var shipping = JSON.stringify(result.ShippingCity).split(",");
					if(shipping.length > 0){
						component.set("v.shippingSubDistrict", shipping[0]);
						component.set("v.shippingDistrict", shipping[1]);
					}
				}
			}
			else {
				alert('Unable to fetch data from server');
			}
		});

		// Send action off to be executed
		$A.enqueueAction(action);
	},

	createInsuredInfo : function (component, event, helper){
		var action = component.get("c.saveInsuredInfo");

		var currentStep = parseInt(component.get('v.currentStep'));

		console.log(currentStep);

		// Get District & Sub-District
		var billingDistrict = component.get("v.billingDistrict");
		var billingSubDistrict = component.get("v.billingSubDistrict");

		var shippingDistrict = component.get("v.shippingDistrict");
		var shippingSubDistrict = component.get("v.shippingSubDistrict");

		// Set District & Sub-District to object
		var ld = component.get("v.ld");

		// Check value and set value to Object
		if(billingSubDistrict != null && billingSubDistrict != ""){
			ld.City__c = billingSubDistrict;
			if(billingDistrict != null && billingDistrict != ""){
				ld.City__c = billingSubDistrict + "," + billingDistrict;
			}
		}
		if(shippingSubDistrict != null && shippingSubDistrict != ""){
			ld.City = shippingSubDistrict;
			if(shippingDistrict != null && shippingDistrict != ""){
				ld.City = shippingSubDistrict + "," + shippingDistrict;
			}
		}

		action.setParams({ 'ld' : ld });

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var resultAcccount = response.getReturnValue();

				console.log('Result Lead : '+ JSON.stringify(resultAcccount));

				var currentStep = parseInt(component.get('v.currentStep'));
				currentStep = currentStep + 1;
				
				component.set('v.currentStep',currentStep+'' );
			}
			else {
				alert('Unable to fetch data from server');
			}
		});

       $A.enqueueAction(action);    
	},


})