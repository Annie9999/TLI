({
    showToast : function(component, event, helper,type,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": message,
            "type" : type,
            "message": '', 
        });
        toastEvent.fire();
    }
})