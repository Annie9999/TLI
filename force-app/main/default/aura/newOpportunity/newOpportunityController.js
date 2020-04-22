({
    doInit : function(component, event, helper) {
        var recordId =  component.get("v.recordId");
        var action = component.get("c.getOpportunity");
        action.setParams({ 
            "oppId": recordId
            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var opptyRecord = response.getReturnValue();
                console.log('Return opptyRecord: ',JSON.parse(JSON.stringify(opptyRecord)));
                component.set("v.oppty", opptyRecord);
                
                component.set("v.accountName", opptyRecord.Account.FirstName +' '+ opptyRecord.Account.LastName);
                
                //component.set("v.opptyRecord", opptyRecord);
                //component.set("v.accountName", opptyRecord.Account.FirstName +' '+ opptyRecord.Account.LastName);
                
            }
        });
        $A.enqueueAction(action)  
    },
    
    saveOppty : function(component, event, helper) {
        var oppty =  component.get("v.oppty");        
        console.log('oppty:  ',JSON.parse(JSON.stringify(oppty)));
        
        var action = component.get("c.saveOpportunity");
        action.setParams({ 
            "oppty": oppty
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                
                var toastEvent = $A.get("e.force:showToast");
                var opptyId = response.getReturnValue();
                console.log('Return opptyId: '+opptyId);
                
                if(opptyId != null){
                    console.log('good');
                    toastEvent.setParams({
                        "title": "สำเร็จ",
                        "message": "สร้าง Opportunities สำเร็จ",
                        "type": "success"
                    });
                    toastEvent.fire();
                    helper.openTab(component, opptyId);
                }else{
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
    /*  openTab : function(component, event, helper) {
           var recordId =  component.get("v.recordId");

           
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
          	 url: '/lightning/r/Opportunity/'+ component.get("v.recordId") +'/view',

            focus: true
        });
    },*/
    
})