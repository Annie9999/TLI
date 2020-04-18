({
    doInit : function(component, event, helper) {
        console.log(component.get('v.assetId'));
        helper.callServer(
            component,
            "c.getVehicle",
            function (response) {
                component.set("v.vehicle", response);
                //helper.onResize(component, helper);
            },
            { 
                vehicleId : component.get("v.recordId")
            }
        );
    },
    selectPolicy : function(component, event, helper) {
        var selectEvent = component.getEvent('selectVehicleEvent');
        selectEvent.setParams({
            'selectedId' : component.get('v.recordId'),
            'assetId' : component.get('v.assetId')
        });
        selectEvent.fire();
    }
})