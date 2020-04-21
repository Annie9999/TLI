({
	doInit: function(component, event, helper) {
        var status = component.get("v.status");
        console.log('status: '+status);
        // Call Helper
        helper.getInsuredInfo(component, event, helper);
    },

    createInsuredInfo: function(component, event, helper) {
        // Call Helper
        helper.createInsuredInfo(component, event, helper);
    },

    toggle : function(component,event,helper){
        var elements = document.getElementById("currentAddress");
        var chk = document.getElementById("sameAddress");
        if(chk.checked){
            elements.style.display = 'none';
        }
        else{
            elements.style.display = 'block';
        }
    },
})