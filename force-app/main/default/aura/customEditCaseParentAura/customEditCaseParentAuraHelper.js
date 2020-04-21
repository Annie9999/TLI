({
    onInIt: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var pageReference = component.get("v.pageReference");
        var param1 = pageReference.state.c__recordId;  

        // console.log('state re ==> : ',pageReference.state.RecordTypeId )

        var objectApiName = pageReference.state.c__objType;
        var recTypeId = pageReference.state.c__recTypeId; 
        var objName = component.get("v.sObjectName");
        if(param1 == null || param1 == '' || param1 == undefined){
            param1 = component.get("v.recordId");
        }
        if(objectApiName == null || objectApiName == '' || objectApiName == undefined){
            objectApiName = component.get("v.ObjectType");
        }
        if(recTypeId == null || recTypeId == '' || recTypeId == undefined){
            recTypeId = component.get("v.recTypeId");
            // console.log('recTypeId new : ',recTypeId)
            // recTypeId = component.get("v.pageReference").state.recordTypeId;
            recTypeId = component.get("v.pageReference").state.recordTypeId;
            // console.log('recTypeId new 2 : ',recTypeId)
        }
        // console.log('param1 : '+param1);
        // console.log('objectApiName : '+objectApiName);
        // console.log('recTypeId : '+recTypeId);
        
        var recId = param1;
        
        if( recId == null || recId == '' || recId == undefined ){              	      
            var state = pageReference.state; 	       
            var base64Context = state.inContextOfRef;	               
            if (base64Context.startsWith("1\.")) {	            
                base64Context = base64Context.substring(2);	             
            }	        
            var addressableContext = JSON.parse(window.atob(base64Context));	        
            // console.log('addressableContext = '+JSON.stringify(addressableContext));	        
            recId = addressableContext.attributes.recordId;
            objectApiName = addressableContext.attributes.objectApiName;
            recTypeId = addressableContext.attributes.recTypeId;
            // console.log('recTypeId : ',recTypeId);
            // console.log('recId : ',recId);
            // console.log('objectApiName : ',objectApiName);
            component.set('v.recordId', recId );
            component.set('v.ObjectType', objectApiName );
            component.set('v.recTypeId', recTypeId );
            component.set('v.sObjectName', objName );
            
            
        }else{
            component.set('v.recordId', recId );
            component.set('v.ObjectType', objectApiName );
            component.set('v.recTypeId', recTypeId );
            component.set('v.sObjectName', objName )
        }
    }
})