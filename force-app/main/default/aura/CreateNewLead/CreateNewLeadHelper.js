({
    
    saveLead : function(component, event, helper) {
        console.log('------saveLead------');
        
        var toastEvent = $A.get("e.force:showToast");
        var leads =  component.get("v.leads");   
        console.log('leads:  ',JSON.parse(JSON.stringify(leads)));
        
        var action = component.get("c.saveNewLead");
        action.setParams({ 
            "leads": leads
        });
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var leadId = response.getReturnValue();
                console.log('Return leadId: ',JSON.parse(JSON.stringify(leadId)));
                if(leadId != null){
                    console.log('good');
                    toastEvent.setParams({
                        "title": "สำเร็จ",
                        "message": "สร้าง Opportunities สำเร็จ",
                        "type": "success"
                    });
                    toastEvent.fire();
                    helper.openTab(component, leadId);
                } else{
                    console.log('bad');
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "สามารถสร้าง Opportunity ได้เฉพาะกรณีที่ไม่ผ่านการอนุมัติ",
                        "type": "error"
                    });
                    toastEvent.fire();
                }      
            }
        });
        $A.enqueueAction(action)  
        
        
    },
    
    
    
	 openTab : function(component,leadId) {
        console.log('------New tab------');

        console.log('leadId: ' +leadId);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Lead/'+ leadId +'/view',
            
            focus: true
        });
    },   
})