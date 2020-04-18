({
  
    openPop : function(component, event, helper) {
    var dname = component.get("v.productFamily");
    var cmpTarget = component.find(dname);
    $A.util.addClass(cmpTarget, 'slds-show');
    $A.util.removeClass(cmpTarget, 'slds-hide');

},

	closePop : function(component, event, helper) {
    var dname = component.get("v.productFamily");
    var cmpTarget = component.find(dname);
    $A.util.addClass(cmpTarget, 'slds-hide');
    $A.util.removeClass(cmpTarget, 'slds-show');

}
})