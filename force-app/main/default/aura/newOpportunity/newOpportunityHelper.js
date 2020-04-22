({
    openTab : function(component,opptyId) {
        console.log('------New tab------');

        console.log('opptyId: ' +opptyId);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Opportunity/'+ opptyId +'/view',
            
            focus: true
        });
    },   
})