({
    doInit : function(component, event, helper) {

        var status = component.get("v.status");
        console.log('status: '+status);

        //const input  = component.find('status');
       /* var div = cmp.find("theDiv");

        if (div) {
            console.log('div: '+div);
        }*/
       // component.find("myId").set("v.disabled", true); 

       /* var status = component.get("v.status");
        var inpAcc = document.getElementById("dcalc");
            inpAcc.setAttribute("disabled","true");*/ 

       // $("[id$=dcacl]").prop("disabled",true);

      //  $("#dcacl").attr('disabled',status);

       /* var status = component.get("v.status");
        var value = event.currentTarget.dataset.type;
        console.log(value);
        //var div = event.currentTarget;
      //  var recordId = div.getAttribute('data-record-id');
       // console.log('recordId: '+recordId);
       
        if(status == true){
            console.log('status: '+status);

        //    $('.paymentType').attr('disabled', true);


        }*/
        


        helper.setDefault(component);
        helper.functionGetOption(component, helper);
    },

    updateSelectedText : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows ' , selectedRows[0].id);
        console.log('selectedRows ' , selectedRows[0].bankName);
    },

    changePayment : function(component, event, helper){
        var paymentValue = event.target.dataset.value;
        var paymentType = event.target.dataset.type;
        helper.setPaymentType(component, helper, paymentValue, paymentType);
    },

    changeAddressType : function(component, event, helper){
        var addressType = event.getSource().get("v.value");
        console.log('addressType : ' + addressType);
        component.set('v.addressType', addressType);

    },

    getRefNumber : function(component, event, helper){
        component.set('v.paymentInfo.payment.REF_Number__c', 'TLIS2374');
    },

    savePaymentInfo : function(component, event, helper){
        helper.functionSavePaymentInfo(component, helper);
    },

    setBankAccountType : function(component, event, helper){
        var paymentType = event.getSource().get("v.value");
        console.log('paymentType' + paymentType);
        component.set('v.paymentInfo.payment.Bank_Account_Type__c', paymentType);
    },
    
    
})