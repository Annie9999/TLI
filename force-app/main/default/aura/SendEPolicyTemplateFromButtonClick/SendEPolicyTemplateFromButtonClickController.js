({
	init : function(component, event, helper) {
      var recordId = component.get("v.recordId");
      var action = component.get("c.getOpportunity");
      action.setParams({"insurancePolicyId": recordId});
      action.setCallback(this, function(response) {
         var state = response.getState();
         if(component.isValid() && state == "SUCCESS"){
             var opportunity = response.getReturnValue();
             component.set("v.textName", opportunity[0].Account.Name);
             component.set("v.textEmail", opportunity[0].Account.PersonEmail);
             component.set("v.destinationOppId", opportunity[0].Id);
         } else {
            component.set("v.messageError", true);
         }
      });
      $A.enqueueAction(action);
   },
      sendEmail : function(component, event, helper) {
      var destinationOppId = component.get("v.destinationOppId");
      var action = component.get("c.executeOnButtonClick");
      action.setParams({"opportunityId": destinationOppId});
      action.setCallback(this, function(response) {
         var state = response.getState();
         if(component.isValid() && state == "SUCCESS"){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Success!",
               "message": "Email has been sent success!",
               "type": "success"
            });
            toastEvent.fire();
         } else {
            component.set("v.messageError", true);
         }
      });
      $A.enqueueAction(action);
   }
})