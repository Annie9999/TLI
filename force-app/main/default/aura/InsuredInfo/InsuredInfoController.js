({
	doInit: function(component, event, helper) {
        var status = component.get("v.status");
        console.log('status: '+status);
        // Call Helper
        helper.getInsuredInfo(component, event, helper);
    },

    createInsuredInfo: function(component, event, helper) {
        // Call Helper
        helper.createInsuredInfo(component, event, helper);
    },

    toggle : function(component,event,helper){
        var elements = document.getElementById("currentAddress");
        var chk = document.getElementById("sameAddress");
        if(chk.checked){
            // Set copy Current Address from ที่อยู่ตามทะเบียนบ้าน
            // component.get();

            // var shippingStreet = component.get("v.newAcc.ShippingStreet");
            // var shippingDistrict = component.get("v.shippingDistrict");
            // var shippingSubDistrict = component.get("v.shippingSubDistrict");
            // var shippingState = component.get("v.newAcc.ShippingState");
            // var shippingPostalCode = component.get("v.newAcc.ShippingPostalCode");
            
            // component.set('v.newAcc.ShippingStreet', shippingStreet);
            // component.set('v.shippingSubDistrict', shippingSubDistrict);
            // component.set('v.shippingDistrict', shippingDistrict);
            // component.set('v.newAcc.ShippingState', shippingState);
            // component.set('v.newAcc.ShippingPostalCode', shippingPostalCode);

            elements.style.display = 'none';
        }
        else{
            // Clear Current Address
            // component.set('v.newAcc.ShippingStreet', '');
            // component.set('v.shippingSubDistrict', '');
            // component.set('v.shippingDistrict', '');
            // component.set('v.newAcc.ShippingState', '');
            // component.set('v.newAcc.ShippingPostalCode', '');

            elements.style.display = 'block';
        }
    },
})