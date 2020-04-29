// eslint-disable-next-line no-unused-expressions
({
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        
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
                component.set('v.TypeQuotation',false);
            }else{
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    functionTypePrice : function(component, event, helper) {
        var subProductValue = component.get('v.objDetail.Sub_productgroup__c');
        var genderValue = component.get('v.genderValue');
        var paymentmethidValue = component.get('v.paymentmethidValue');
        var birthdate = component.get('v.opptyRecord.Date_Of_Birth__c');        
        var price = 1200.50;
        var today = new Date();
        if(birthdate !== undefined){
            console.log('H');
            var year = Number(birthdate.substr(0, 4));
            var month = Number(birthdate.substr(5, 2))-1;
            var day = Number(birthdate.substr(8, 2));
            var age = today.getFullYear() - year;
    
            if (today.getMonth() < month || (today.getMonth() == month && today.getDate() < day)) {
                age = age-1;
            }    

        }
        console.log('Age: ' + age);        
        console.log('subProductValue: ' + subProductValue);
        console.log('genderValue: ' + genderValue);
        console.log('paymentmethidValue: ' + paymentmethidValue);

        if(subProductValue !== '' && genderValue !== '' && paymentmethidValue  !== '' && birthdate!==undefined) {           
            price += age*5.725;
            if(genderValue === 'F'){
                price += 500.00;
            }

            if(paymentmethidValue === 'ราย 3 เดือน'){
                price *= 3;
                price -= 10.275;
            } else if(paymentmethidValue === 'ราย 6 เดือน'){
                price *= 6;
                price -= 65.5;
            } else if(paymentmethidValue === 'รายปี'){
                price *= 12;
                price -= 159.5;
            }
            component.set("v.amount", price);
        }
        
    },
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
    functionSave : function(component, event, helper) {
        
        var action = component.get('c.saveACCProduct');
        var recordId = component.get('v.recordId');
        var product = component.get('v.objDetail.productgroup__c');
        var subProduct = component.get('v.objDetail.Sub_productgroup__c');
        var birthdate = component.get('v.opptyRecord.Date_Of_Birth__c');
        var gender = component.get('v.genderValue');
        var amount = component.get('v.amount');
        var payment = component.get('v.paymentmethidValue');
        console.log('==== save ====');
        amount = amount.toFixed(2);
        if(gender==='M'){
            gender = 'ชาย';
        }
        else{
            gender = 'หญิง';
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
        console.log('action ' + action);
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
                component.set("v.saveSuccess", true);
            }else{
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },


    functionCheckSaveBtn: function(component, event, helper){
        var checkBtn = component.get('v.checkBtn');
        var product = component.get('v.objDetail.productgroup__c');
        var subProduct = component.get('v.objDetail.Sub_productgroup__c');
        var birthdate = component.get('v.opptyRecord.Date_Of_Birth__c');
        
        var gender = component.get('v.genderValue');
        var payment = component.get('v.paymentmethidValue');

        console.log('product= '+product);
        console.log('subProduct= '+subProduct);
        console.log('birthdate= '+birthdate);
        console.log('gender= '+gender);        
        console.log('payment= '+payment);        

        if(product == '--- None ---' || subProduct == '--- None ---' || birthdate == null || gender == '' || payment == ''){
            component.set('v.checkBtn',true);
            component.set('v.amount',0);
        }else{
            component.set('v.checkBtn',false);
        }
    },


    
})