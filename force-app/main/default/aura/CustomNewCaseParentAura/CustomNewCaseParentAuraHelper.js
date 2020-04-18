({
    onInIt: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var pageReference = component.get("v.pageReference");
        var param1 = pageReference.state.c__recordId;  
        var objectApiName = pageReference.state.c__objType;
        var recTypeId = pageReference.state.c__recTypeId;  
        console.log('param1 : '+param1);
        console.log('objectApiName : '+objectApiName);
        console.log('recTypeId : '+recTypeId);
        
        var recId = param1;
        
        if( recId == null || recId == '' || recId == undefined ){            
            recId = recId;        	      
            var state = pageReference.state; 	
            console.log(state);        
            var base64Context = state.inContextOfRef;	               
            if (base64Context.startsWith("1\.")) {	            
                base64Context = base64Context.substring(2);	             
            }	        
            var addressableContext = JSON.parse(window.atob(base64Context));	        
            console.log('addressableContext = '+JSON.stringify(addressableContext));	        
            recId = addressableContext.attributes.recordId;
            objectApiName = addressableContext.attributes.objectApiName;
            recTypeId = addressableContext.attributes.recTypeId;
            console.log('objectApiName = '+JSON.stringify(objectApiName));
            console.log('addressableContext = '+JSON.stringify(objectApiName));
            component.set('v.recordId', recId );
            component.set('v.ObjectType', objectApiName );
            component.set('v.recTypeId', recTypeId );
            
        }else{
            console.log('objectApiName = '+JSON.stringify(objectApiName));
            component.set('v.recordId', recId );
            component.set('v.ObjectType', objectApiName );
            component.set('v.recTypeId', recTypeId );
        }
        
        
        
        
    }

})