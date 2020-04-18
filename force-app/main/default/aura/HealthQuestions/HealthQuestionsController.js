({
    doInit : function(component, event, helper) {

        helper.getQuestion(component, event,helper);   
    },
    
    saveQA : function(component, event, helper) {

        helper.saveQA(component, event,helper);   
 
    },
    
    updateQA : function(component, event, helper) {
        console.log('-----updateQA-----');
        helper.updateQA(component, event,helper);   
       // helper.functionNextPage(component, event, helper);
    },
   
})