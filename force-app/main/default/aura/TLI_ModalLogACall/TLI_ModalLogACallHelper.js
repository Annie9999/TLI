({
    displayToast: function (component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    },
    refreshFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            console.log('response ',response);
            
            workspaceAPI.refreshTab({
                        tabId: focusedTabId,
                        includeAllSubtabs: true
                });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})