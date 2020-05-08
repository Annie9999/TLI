({
    // Sets an empApi error handler on component initialization
    onInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        const empApi = component.find("empApi");
        // Get the channel from the input box.
        var channel = component.find("channel").get("v.value");
        const replayId = -1;

        // Callback function to be passed in the subscribe call.
        // After an event is received, this callback prints the event
        // payload to the console.
        const callback = function (message) {
            console.log("Event Received : " + JSON.parse(JSON.stringify(message)));
            var payload = message.data.payload;
            // console.log("Event Received : " + msg);
            console.log('recordId ',recordId);
            console.log('payload.WhoId__c ',payload.WhoId__c);
            
            if(payload.WhoId__c == recordId){
                component.set('v.showModalEmail',true);
            }
        };

        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, callback).then(function(newSubscription) {
            console.log("Subscribed to channel " + channel);
            component.set("v.subscription", newSubscription);
        });
    },
    onClickAutoSendEmail: function(component, event, helper) {
        
        /*
        component.set('v.loading', true);
         **** method send email
         */
        var recordId = component.get("v.recordId");
        var action = component.get("c.sendMailByTemplate");
        action.setParams({
            leadId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseValue = response.getReturnValue();
                console.log('responseValue : ',responseValue);
                
                helper.displayToast(component,'success','ส่งอีเมลล์แล้ว');
                component.set('v.showModalEmail', false);
                component.set('v.showModalTransfer' ,true);
                component.set('v.loading', false);
            }
            else {
                var error = response.getError();
                console.log(error[0].message);
                if( error[0].message.includes('The target object\'s email address \"null\" is not valid')){
                    error[0].message = 'กรุณาใส่อีเมลก่อนส่งอีเมล';
                }
                helper.displayToast(component,'error',error[0].message);
                component.set('v.showModalEmail', false);
                component.set('v.showModalTransfer' ,true);
                component.set('v.loading', false);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
        

       
        
    },
    onCancelSentEmail : function(component, event, helper) {
        component.set('v.showModalEmail', false);
        component.set('v.showModalTransfer' ,true);
    },
    onClickTransferDM : function(component, event, helper) {
        console.log('action ');
        component.set('v.loading', true);
        var action = component.get("c.transferRecordTypeToDM");
        var recordId = component.get("v.recordId");
        console.log('recordId '+recordId);
		// Add callback behavior for when response is received
		action.setParams({
            leadId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseValue = response.getReturnValue();
                console.log('responseValue : ',responseValue);
                
                helper.displayToast(component,'success','Lead นี้ได้ถูกทำการโอนเปลี่ยนไปให้ทีม DM แล้ว');
                component.set('v.showModalTransfer' ,false);
                component.set('v.loading', false);
                helper.refreshFocusedTab(component, event, helper);
            }
            else {
                var error = response.getError();
                console.log(error[0].message);
                helper.displayToast(component,'error',error[0].message);
                component.set('v.showModalTransfer' ,false);
                component.set('v.loading', false);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
        
        
    },
    onCancelTransferDM : function(component, event, helper) {
        component.set('v.showModalTransfer' ,false);
    },
    refreshFocusedTab : function(component, event, helper) {
        helper.refreshFocusedTab(component, event, helper);
    },
   

  
})