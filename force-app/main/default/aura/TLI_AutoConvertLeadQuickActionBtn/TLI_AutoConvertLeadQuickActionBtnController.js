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
		console.log('workspaceAPI 1 : ',JSON.parse(JSON.stringify(workspaceAPI)));
		
		console.log('isOpenTab',"openTab" in workspaceAPI);
		console.log('openSubTab',"openSubtab" in workspaceAPI);
        workspaceAPI.openTab({
            url: '/lightning/r/Account/'+accId+'/view',
            focus: true
        }).then(function(response) {
			console.log('tabId ',response);
			// setTimeout(() => {
			
			console.log('workspaceAPI 2 : ',JSON.parse(JSON.stringify(workspaceAPI)));
			console.log('isOpenTab',"openTab" in workspaceAPI);
			console.log('openSubTab',"openSubtab" in workspaceAPI);

				workspaceAPI.openSubtab({
					parentTabId: response,
					url: '/lightning/r/Opportunity/'+oppId +'/view',
					focus: true
				}).then(function(res){
					console.log('res :',JSON.parse(JSON.stringify(res)));
				}).catch(function(error4){
					console.log('ssss :',JSON.parse(JSON.stringify(error4)));
					
				});
			// }, 5000);
			
		}).catch(function(error) {
			console.log(JSON.parse(JSON.stringify(error)));
		});
		workspaceAPI.getFocusedTabInfo().then(function(response) {
			var focusedTabId = response.tabId;
			workspaceAPI.closeTab({tabId: focusedTabId});
		});
			
		
	}
	
})