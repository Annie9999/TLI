({
    doInit : function(component, event, helper) {
        helper.callServer(
            component,
            "c.getVehicles",
            function (response) {
                component.set("v.vehicles", response);
            },
            { 
                policyId : component.get("v.recordId") 
            }
        );
    },
    handleSelect : function(component, event, helper) {
        var vehicleId = event.getParam('selectedId');
        component.set('v.selectedVehicleId', vehicleId);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({ 
            "recordId":     vehicleId, 
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})