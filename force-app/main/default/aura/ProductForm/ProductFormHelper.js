({
    functionSaveAndSendEmail : function(component, event, helper) {
        console.log('functionSaveAndSendEmail');
        $A.util.removeClass(component.find('loading'), 'slds-hide');
        var action = component.get('c.saveProduct');
        var recordId = component.get('v.recordId');

        var product = component.get('v.objDetail.productgroup__c');
        var subProduct = component.get('v.objDetail.Sub_productgroup__c');
        var birthdate = component.get('v.accRecord.PersonBirthdate');
        var gender = component.get('v.genderValue');
        var amount = component.get('v.price');
        var payment = component.get('v.paymentmethidValue');
        if(gender=='M'){
            gender = 'ชาย';
        }
        else{
            gender = 'หญิง';
        }

        if(payment=='1_month'){
            payment = 'รายเดือน';
        }
        else if(payment=='3_months'){
            payment = 'ราย 3 เดือน';
        }
        else if(payment=='6_months'){
            payment = 'ราย 6 เดือน';
        }
        else if(payment=='year'){
            payment = 'รายปี';
        }

        action.setParams({
            'opptyId' : recordId,
            'product' : product,
            'subProduct' : subProduct,
            'birthdate' : birthdate,
            'gender' : gender,
            'payment' : payment,
            'amount' : amount
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Success');
                // functionSendQuotation
                helper.functionSendQuotation(component, event, helper);
            }else{
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    functionSendQuotation : function(component, event, helper) {
        var action = component.get("c.sendQuotation");
        var recordId = component.get('v.recordId');
        
        action.setParams({
            opptyId : recordId,
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                console.log('Success');
                // component.set('v.TypeQuotation',false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'สำเร็จ',
                    message: 'จัดส่งใบเสนอราคาให้ท่านแล้ว',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            }else{
                console.log('Error');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'ไม่สำเร็จ',
                    message: 'เกิดข้อผิดพลาด',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            $A.util.addClass(component.find('loading'), 'slds-hide');
        });
        $A.enqueueAction(action);
    },
    functionTypePrice : function(component, event, helper) {
        var genderValue = component.get('v.genderValue');
        var paymentmethidValue = component.get('v.paymentmethidValue');
        var TypePrice = component.get('v.TypePrice');
        console.log('/// '+genderValue);
        console.log('/// '+paymentmethidValue);
        console.log('/// '+TypePrice);
        if(genderValue != '' && paymentmethidValue != ''){
            component.set('v.TypePrice',genderValue+paymentmethidValue );
        }else{
            component.set('v.TypePrice','Default');
        }

        var AfTypePrice = component.get('v.TypePrice');
        console.log('///ss '+AfTypePrice);
        if(AfTypePrice=='F1_month'){
            component.set('v.price','2345.65');
        }
        else if(AfTypePrice=='M1_month'){
            component.set('v.price','3345.65');
        }
        else if(AfTypePrice=='F3_months'){
            component.set('v.price','6345.65');
        }
        else if(AfTypePrice=='M3_months'){
            component.set('v.price','7345.65');
        }
        else if(AfTypePrice=='F6_months'){
            component.set('v.price','12345.65');
        }
        else if(AfTypePrice=='M6_months'){
            component.set('v.price','14345.65');
        }
        else if(AfTypePrice=='Fyear'){
            component.set('v.price','22345.65');
        }
        else if(AfTypePrice=='Myear'){
            component.set('v.price','24345.65');
        }
        else{
            component.set('v.price','0.00');
        }
        
    },
    functionSave : function(component, event, helper) {
        console.log('save');
        var action = component.get('c.saveProduct');
        var recordId = component.get('v.recordId');

        var product = component.get('v.objDetail.productgroup__c');
        var subProduct = component.get('v.objDetail.Sub_productgroup__c');
        var birthdate = component.get('v.accRecord.PersonBirthdate');
        var gender = component.get('v.genderValue');
        var amount = component.get('v.price');
        var payment = component.get('v.paymentmethidValue');
        if(gender=='M'){
            gender = 'ชาย';
        }
        else{
            gender = 'หญิง';
        }

        if(payment=='1_month'){
            payment = 'รายเดือน';
        }
        else if(payment=='3_months'){
            payment = 'ราย 3 เดือน';
        }
        else if(payment=='6_months'){
            payment = 'ราย 6 เดือน';
        }
        else if(payment=='year'){
            payment = 'รายปี';
        }

        action.setParams({
            'opptyId' : recordId,
            'product' : product,
            'subProduct' : subProduct,
            'birthdate' : birthdate,
            'gender' : gender,
            'payment' : payment,
            'amount' : amount
        });
        console.log('== '+product); 
        console.log('== '+subProduct); 
        console.log('== '+birthdate); 
        console.log('== '+gender); 
        console.log('== '+payment); 
        console.log('== '+amount); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Success');
                component.set('v.TypeQuotation',false);
                var currentStep = parseInt(component.get('v.currentStep'));
                currentStep = currentStep+1;
                component.set('v.currentStep',currentStep+'' );
            }else{
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    functionAddValuePicklist: function(component,helper,subProduct) {  
        console.log('onControllerFieldChange');
        // var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value

        var controllerValueKey = component.get("v.objDetail.productgroup__c");
        console.log('controllerValueKey '+controllerValueKey);
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields,subProduct);
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
    fetchDepValues: function(component, ListOfDependentFields,subProduct) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        setTimeout(() => {
            component.set("v.objDetail.Sub_productgroup__c", subProduct); 
        }, 200);
    },
})