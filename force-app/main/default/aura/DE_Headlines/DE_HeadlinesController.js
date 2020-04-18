({
    doInit : function(component, event, helper) {
        console.log('{!v.fields.Name}', component.get("v.fields.Name"));
          component.set("v.headLines",'ใกล้วันเกิดคุณ '+ component.get("v.fields.Name") +' แล้ว ***** วันสุดท้ายของโปรโมชั่นเพื่อนช่วยเพือน *****');
         /*
        var rotationType=component.get("v.direction");
        if(rotationType=='scroll_right2left')
        {
              var action = component.get("c.getHeadlines");
        }
        else
        {
			var action = component.get("c.getVerticalHeadlines");            
        }
        action.setParams({ deLimiter : component.get("v.deLimiter") });
       
        
         
        action.setCallback(this, function(response) {
            
          
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
                component.set("v.headLines",response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        */
    },
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        //console.log('test');
        component.set("v.headLines",'ใกล้วันเกิดคุณ '+ component.get("v.fields.Name") +' แล้ว ***** วันสุดท้ายของโปรโมชั่นเพื่อนช่วยเพื่อน *****');
        if(eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));  
            component.find("recordHandler").reloadRecord();

        } else if(eventParams.changeType === "LOADED") {
            // record is loaded in the cache
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving or deleting the record
        }
    },
})