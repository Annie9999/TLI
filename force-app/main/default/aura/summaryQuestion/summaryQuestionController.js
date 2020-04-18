({
    doInit : function(component, event, helper) {

        var order = component.get('v.order');
        var answer = component.get('v.answerList');
        console.log('answer'+answer);
        component.set('v.answer', answer);
    }
})