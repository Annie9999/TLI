({
    doInit : function(component, event, helper) {
        var status =  component.get("v.status");
        console.log('status: '+ status);

        

       /* var stageName =  component.get("v.stageName");
        var status =  component.get("v.status");

        console.log('stageName: '+stageName);
        console.log('status: '+ status);

        if(stageName == 'Closed Won' && status =='QC ปฏิเสธ'){

        }*/




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