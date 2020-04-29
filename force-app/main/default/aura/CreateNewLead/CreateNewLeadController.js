({
    doInit : function(component, event, helper) {
        var recordId =  component.get("v.recordId");
        var action = component.get("c.getLead");
        action.setParams({ 
            "leadId": recordId
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var leadRecord = response.getReturnValue();
                console.log('Return Lead: ',JSON.parse(JSON.stringify(leadRecord)));
                component.set("v.leads", leadRecord);                     
            }
        });
        $A.enqueueAction(action)  
    },
    
    saveLead : function(component, event, helper) {
        
        helper.saveLead(component, event, helper);

    },
})