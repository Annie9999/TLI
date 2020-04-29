({

    setDefault : function(component, helper){
        component.set('v.columns', [
            {label: 'ธนาคาร', fieldName: 'bankName', type: 'text'},
            {label: 'สาขา', fieldName: 'bankBranch', type: 'text'},
            {label: 'เลขที่บัญชี', fieldName: 'bankAccountNumber', type: 'text'},
        ]);

        component.set('v.data', [
            {'id': 'ธนาคารทหารไทย รัชดาภิเษก 054-1-05604-0' ,'bankName': 'ธนาคารทหารไทย', 'bankBranch': 'รัชดาภิเษก', 'bankAccountNumber': '054-1-05604-0'},
            {'id': 'ธนาคารทหารไทย อโศก-ดินแดง 056-6-02293-1' ,'bankName': 'ธนาคารกรุงไทย', 'bankBranch': 'อโศก-ดินแดง', 'bankAccountNumber': '056-6-02293-1'},
            {'id': 'ธนาคารกรุงเทพ อโศก-ดินแดง 185-3-05985-3' ,'bankName': 'ธนาคารกรุงเทพ', 'bankBranch': 'อโศก-ดินแดง', 'bankAccountNumber': '185-3-05985-3'},
            {'id': 'ธนาคารกรุงศรีอยุธยา เอสพลานาด 584-0-00030-5' ,'bankName': 'ธนาคารกรุงศรีอยุธยา', 'bankBranch': 'เอสพลานาด', 'bankAccountNumber': '584-0-00030-5'}
        ]);

        component.set('v.paymentType', {
            'havePayment': false,
            'paymentGatway': true,
            'creditCard': false, 
            'transferBanking' : false,
            'counterService' : false,
            'debitedAccount' : false
        });
    },

    functionGetOption : function(cmp, helper){
        var action = cmp.get("c.getOption");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log('optionSelect ' , returnValue);
                cmp.set('v.optionSelect', returnValue);
                helper.functionGetPaymentinformation(cmp, helper);
            }else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Unknown error" , errors);
                
            }
        });
        $A.enqueueAction(action);
    },

    functionGetPaymentinformation : function(cmp, helper) {
        console.log('Lead Id : ' + cmp.get("v.recordId"));
        var action = cmp.get("c.getPaymentInformation");
        action.setParams({ 
            leadId : cmp.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log('Payment Info ' , returnValue);
                cmp.set('v.paymentInfo', returnValue);
                helper.mappingValue(cmp, helper, returnValue.payment.Payment_Type__c);

            }else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Unknown error" , errors);
                
            }
        });
        $A.enqueueAction(action);
    },

    mappingValue : function(cmp, helper, paymentType){
       
        console.log('paymentType' , paymentType);
        var value = ""; 

        if(paymentType == 'ชำระผ่านบัตรเครดิต'){
            value = "1";
        }else if(paymentType == 'โอนเงินผ่านบัญชีธนาคาร'){
            value = "2";
        }else if(paymentType == 'ชำระผ่านเคาน์เตอร์'){
            value = "3";
        }else if(paymentType == 'หักผ่านบัญชีเงินฝาก'){
            value = "4";
        }else{
            value = "5";
            paymentType = 'Payment Gateway';
        }

        cmp.set('v.loaded', false);
        helper.setPaymentType(cmp, helper, value, paymentType);
    },

    setPaymentType : function(cmp, helper, paymentValue, paymentType){

        console.log('paymentValue : ' + paymentValue);
        var creditCard = false;
        var transferBanking = false;
        var counterService = false;
        var debitedAccount = false;
        var paymentGatway = false;
        switch (paymentValue) {
            case '1':
                creditCard = true;
                break;
            case '2':
                transferBanking = true;
                break;
            case '3':
                counterService = true;
                break;
            case '4':
                debitedAccount = true;
                break;
            case '5':
                paymentGatway = true;
                break;
        }

        var buttonPayment = document.getElementsByClassName('paymentType');
        for (var i = 0; i < buttonPayment.length; i++) {
            var classValue = buttonPayment[i].classList.value;
            if(classValue.includes("paymentType" + paymentValue)){
                buttonPayment[i].classList.add('slds-button_brand');
            }else{
                buttonPayment[i].classList.remove('slds-button_brand');
            }
        }
        
        

        cmp.set('v.paymentType', {
            'havePayment': true,
            'paymentGatway': paymentGatway,
            'creditCard': creditCard, 
            'transferBanking' : transferBanking,
            'counterService' : counterService,
            'debitedAccount' : debitedAccount
        });

        cmp.set('v.paymentInfo.payment.Payment_Type__c', paymentType);
    },

    functionSavePaymentInfo : function(cmp, helper){
        cmp.set('v.loaded', true);
        console.log('functionSavePaymentInfo');
        console.log('paymentInfo', cmp.get("v.paymentInfo"));
        console.log('addressType', cmp.get("v.addressType"));
        var action = cmp.get("c.savePaymentInformation");
        action.setParams({ 
            paymentInfoString : JSON.stringify(cmp.get("v.paymentInfo")),
            leadId : cmp.get("v.recordId"),
            addressType : cmp.get("v.addressType")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Save Success');
                var payType = cmp.get('v.paymentInfo.payment.Payment_Type__c');
                console.log('payType ' + payType);
                helper.checkSendSMS(cmp, helper, payType);
                helper.refreshFocusedTab(cmp);

            }else if (state === "ERROR") {
                cmp.set('v.loaded', false);
                var errors = response.getError();
                console.log("Unknown error" , errors);
                
            }
        });
        $A.enqueueAction(action);

    },

    checkSendSMS : function(cmp,helper, paymentType){
        
        if(paymentType == 'โอนเงินผ่านบัญชีธนาคาร' || paymentType == 'ชำระผ่านเคาน์เตอร์' || paymentType =='หักผ่านบัญชีเงินฝาก'){
            console.log('paymentType' + paymentType);
            helper.functionSendSMS(cmp, helper);
        }
       /* else if(paymentType == 'Payment Gateway'){
            console.log('paymentType' + paymentType);
            helper.functionSendePolicy(cmp, helper);
        }*/
        else{
            console.log('paymentType' + paymentType);
            helper.showToast();
            cmp.set('v.loaded', false);
            // helper.closemodal();
        }
    },

    /*functionSendePolicy : function(cmp, helper){
        var action = cmp.get("c.SendEPolicy");
        action.setParams({ 
            opptyId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('SendEPolicy Success');
                helper.showToast();
                cmp.set('v.loaded', false);
                // helper.closemodal();
            }else if (state === "ERROR") {
                cmp.set('v.loaded', false);
                var errors = response.getError();
                console.log("Unknown error" , errors);
            }
        });
        $A.enqueueAction(action);
    },*/

    functionSendSMS : function(cmp, helper){
        console.log('functionSendSMS');
        var action = cmp.get("c.sendSMS");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Success +++++ ');
                helper.showToast();
                cmp.set('v.loaded', false);
            }else if (state === "ERROR") {
                cmp.set('v.loaded', false);
                var errors = response.getError();
                console.log("Unknown error" , errors);
                
            }
        });
        $A.enqueueAction(action);
    },

    closemodal : function(){
        $A.get("e.force:closeQuickAction").fire() ;
    },

    showToast : function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Payment has been updated successfully.",
            "type" : "success"
        });
        toastEvent.fire();
    },
    refreshFocusedTab : function(component) {
        var workspaceAPI = component.find("workspace");
        console.log('TestTAE');
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                      tabId: focusedTabId,
                      includeAllSubtabs: true
             });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})