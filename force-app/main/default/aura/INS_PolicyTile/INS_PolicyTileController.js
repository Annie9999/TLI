({
	doInit : function(component, event, helper) {
		helper.callServer(
            component,
            "c.getPolicy",
            function (response) {
                component.set("v.policy", response);
                helper.onResize(component, helper);
            },
            { 
                policyId : component.get("v.recordId") 
            }
        );
	},
    selectPolicy : function(component, event, helper) {
        var selectEvent = component.getEvent('selectPolicyEvent');
        selectEvent.setParams({
            'selectedId' : component.get('v.recordId')
        });
        selectEvent.fire();
    }
})