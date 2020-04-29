({
    doInit : function(component, event, helper) {
        /*var status =  component.get("v.status");
        console.log('status: '+ status);*/
        helper.getQuestion(component, event,helper);   
    },
    
    saveQA : function(component, event, helper) {
        helper.saveQA(component, event,helper);    
    },
    
    updateQA : function(component, event, helper) {
        helper.updateQA(component, event,helper);   
    },
    
})