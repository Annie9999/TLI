({
    doInit: function (component, event, helper) {
        console.log('11111');
        helper.onInIt(component, event, helper);
    },
    handleFilterChange: function(component, event) {
         var CloseClicked = event.getParam('close');
        var focusTapId;
        console.log();
        console.log('CloseClicked : '+JSON.stringify(CloseClicked));

        var workspaceAPI = component.find("workspace");
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('getFocusedTabInfo : '+response.tabId);
            focusTapId = response.tabId;
            workspaceAPI.openSubtab({
                parentTabId: response.tabId,
                recordId: CloseClicked.recordCaseId,
                focus: true
            }).then(function(response) {
                console.log(response);
                workspaceAPI.focusTab({tabId : response});

                workspaceAPI.closeTab({tabId: focusTapId});
            })
            .catch(function(error) {
                   console.log(error);
            });

        }).catch(function(error) {
            console.log(error);
        });

    },
    
    
})