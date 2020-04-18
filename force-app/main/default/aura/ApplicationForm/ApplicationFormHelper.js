({
    functionNextPage: function(component, event, helper) {
        console.log('Next');
        var currentStep = parseInt(component.get('v.currentStep'));
        if(currentStep < 4){
            currentStep = currentStep+1;
        }
        if(currentStep == 4){
            setTimeout(() => {
                currentStep = currentStep+1;
                component.set('v.currentStep',currentStep+'' );
            }, 2000);
        }
        console.log('currentStep : '+currentStep);
        
        component.set('v.currentStep',currentStep+'' );
    },

    functionClickPage: function(component, event, helper) {
        console.log('Next');
        var currentStep = parseInt(event.getSource().get("v.value"));
        console.log('currentStep : '+currentStep);
        component.set('v.currentStep',currentStep+'' );
    }

})