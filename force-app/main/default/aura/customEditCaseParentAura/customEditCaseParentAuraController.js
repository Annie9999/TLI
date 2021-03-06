({
    doInit: function (component, event, helper) {
        // console.log('11111');
        helper.onInIt(component, event, helper);
    },
    // closeFocusedTab : function(component, event, helper) {
    //     var workspaceAPI = component.find("workspace");
    //     workspaceAPI.getFocusedTabInfo().then(function(response) {
    //         var focusedTabId = response.tabId;
    //         workspaceAPI.closeTab({tabId: focusedTabId});
    //     })
    //     .catch(function(error) {
    //         console.log(error);
    //     });
    // },
    handleFilterChange: function(component, event) {
        var CloseClicked = event.getParam('close');
        component.set('v.message', 'Close Clicked');
        
        // console.log('พี่อาร์ม พี่อาร์ม พี่อาร์ม');
        // console.log('พี่บอส พี่บอส พี่บอส');
        // console.log('CloseClicked.recordCaseId : ',CloseClicked.recordCaseId)
        // component.set('v.recordId', recId );
        // console.log('recId : ',recId)
        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getFocusedTabInfo().then(function(response) {
        //     var focusedTabId = response.tabId;
        //     workspaceAPI.closeTab({tabId: focusedTabId});
        // })
        // .catch(function(error) {
        //     console.log(error);
        // });

        // var CloseClicked = event.getParam('close');
        // var focusTapId;
        // console.log();
        // console.log('CloseClicked : '+JSON.stringify(CloseClicked));

        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getFocusedTabInfo().then(function(response) {
        //     console.log('getFocusedTabInfo : '+response.tabId);
        //     focusTapId = response.tabId;
        //     workspaceAPI.openSubtab({
        //         parentTabId: response.tabId,
        //         recordId: CloseClicked.recordCaseId,
        //         focus: true
        //     }).then(function(response) {
        //         console.log(response);
        //         workspaceAPI.focusTab({tabId : response});

        //         workspaceAPI.closeTab({tabId: focusTapId});
        //     })
        //     .catch(function(error) {
        //            console.log(error);
        //     });

        // }).catch(function(error) {
        //     console.log(error);
        // });




        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            // console.log('response : ',response);
            var focusedTabId = response.tabId;
            // console.log('focusedTabId : ',focusedTabId);

            //Closing old one
            workspaceAPI.closeTab({tabId: focusedTabId});

            //Opening New Tab
            workspaceAPI.openTab({
                url: '/lightning/r/Case/' + CloseClicked.recordCaseId + '/view'
                // url: '#/Case/' + CloseClicked.recordCaseId + '/view'
            }).then(function(response) {
                // console.log('then response : ',response)
                workspaceAPI.focusTab({tabId : response});
            })
            .catch(function(error) {
                console.log(error);
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
})