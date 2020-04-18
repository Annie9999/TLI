({
    afterRender : function(component, helper) {
        var afterRender = this.superAfterRender();
        window.addEventListener('resize', $A.getCallback(function() {
            helper.onResize(component, helper);
        }));
        return afterRender;
    }
})