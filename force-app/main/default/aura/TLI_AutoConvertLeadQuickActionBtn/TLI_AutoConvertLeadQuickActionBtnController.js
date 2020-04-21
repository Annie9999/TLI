({
	closeQA : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},

	closeandrefresh : function(component, event, helper){
		$A.get('e.force:refreshView').fire();
		$A.get("e.force:closeQuickAction").fire();
	},
	onOpenTabAndSubTab : function(component, event, helper) {
		// $A.get("e.force:closeQuickAction").fire();
		console.log(event.getParam('accId'));
		console.log(event.getParam('oppId'));
		var accId = event.getParam('accId');
		var oppId = event.getParam('oppId');
		var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Account/'+accId+'/view',
            focus: true
        }).then((response) => {
			workspaceAPI.openSubtab({
                parentTabId: response,
                url: '/lightning/r/Opportunity/'+oppId +'/view',
                focus: true
            });
		}).catch(function(error) {
			console.log(error);
		});;
		
	}
	
})