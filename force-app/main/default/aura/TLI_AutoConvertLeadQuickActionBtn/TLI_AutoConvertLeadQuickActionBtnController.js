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
		console.log('event.getParam(accId)',event.getParam('accId'));
		console.log('event.getParam(oppId)',event.getParam('oppId'));
		var accId = event.getParam('accId');
		var oppId = event.getParam('oppId');
		var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Account/'+accId+'/view',
            focus: true
        }).then((response) => {
			console.log('tabId ',response);
			// setTimeout(() => {
				workspaceAPI.openSubtab({
					parentTabId: response,
					url: '/lightning/r/Opportunity/'+oppId +'/view',
					focus: true
				});
			// }, 1500);
			
		}).catch(function(error) {
			console.log(JSON.parse(JSON.stringify(error)));
		});
		
	}
	
})