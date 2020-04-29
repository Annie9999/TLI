({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
       
        if(device != 'DESKTOP'){
            // window.location.href = 'myApp://main';
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "myApp://main"
            });

            urlEvent.fire();
        }else{
            component.set('v.isOpen',true);
        }
    },
    closeQuickAction : function(component, event, helper){
        var wasDismissed = $A.get("e.force:closeQuickAction");
        wasDismissed.fire();
    }
})