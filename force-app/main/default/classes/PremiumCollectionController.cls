public class PremiumCollectionController {

    @InvocableMethod(label='Create Premium Collection')
    public static void createPremiumCollection(List<InsurancePolicy> insuredPolicy){
        
        String policyId = insuredPolicy[0].Id;

        InsurancePolicy poli = [SELECT Id, Name, PremiumAmount, PremiumFrequency, Status, PaymentDueDate 
                                    FROM InsurancePolicy
                                    WHERE Id =:policyId 
                                    ORDER BY LastModifiedDate DESC LIMIT 1];  

        System.debug('InsurancePolicy :'+ poli);

        Date dueDate = Date.today();
        List<Premium__C> listPremium = new List<Premium__C>();
        List<Task> listTask = new List<Task>();

        if (poli.PremiumFrequency == 'Monthly') {
            for (Integer i = 1; i <= 11; i++) {

                // Create Premium Collection
                Premium__C pc = new Premium__C();
                pc.Name = 'Premium Collection #' + i;
                pc.Insurance_Policy__c = poli.Id;
                pc.Insurance_Type__c = 'ปีแรก';
                pc.Followup_Result__c = 'Wait';
                pc.Premium_Amount__c = Double.valueOf(poli.PremiumAmount);
                pc.Payment_Due_Date__c = dueDate.addMonths(1*i);
                pc.Payment_Date__c = dueDate.addMonths(1*i).addDays(5);

                System.debug('Result Collection : ' + pc);

                listPremium.add(pc);

                System.debug('Success Create Premium Collection.');
            }
        } else if(poli.PremiumFrequency == 'Quarterly'){
            for (Integer i = 1; i <= 3; i++) {
                Premium__C pc = new Premium__C();
                pc.Name = 'Premium Collection #' + i;
                pc.Insurance_Policy__c = poli.Id;
                pc.Insurance_Type__c = 'ปีแรก';
                pc.Followup_Result__c = 'Wait';
                pc.Premium_Amount__c = Double.valueOf(poli.PremiumAmount);
                pc.Payment_Due_Date__c = dueDate.addMonths(3*i);
                pc.Payment_Date__c = dueDate.addMonths(3*i).addDays(5);

                System.debug('Result Collection : ' + pc);

                listPremium.add(pc);

                System.debug('Success Create Premium Collection.');
            }
        } else if(poli.PremiumFrequency == 'Semi Annual(twice a year)'){
                Integer i = 1;
                Premium__C pc = new Premium__C();
                pc.Name = 'Premium Collection #' + i;
                pc.Insurance_Policy__c = poli.Id;
                pc.Insurance_Type__c = 'ปีแรก';
                pc.Followup_Result__c = 'Wait';
                pc.Premium_Amount__c = Double.valueOf(poli.PremiumAmount);
                pc.Payment_Due_Date__c = dueDate.addMonths(6*i);
                pc.Payment_Date__c = dueDate.addMonths(6*i).addDays(5);
                
                System.debug('Result Collection : ' + pc);

                listPremium.add(pc);

                System.debug('Success Create Premium Collection.');
        } else {
            System.debug('Can not create Premium Collection.');
        }

        System.debug('Result Collections List : ' + listPremium);

        insert listPremium;

        // Create Task to DM Collection
        for (Premium__C premium : listPremium) {
            Task tasks = new Task();
            //tasks.WhoId = opp.AccountId;
            tasks.subject = 'ติดตามเบี้ยประกัน ' + poli.Name;
            tasks.OwnerId = '005q0000006NE2vAAG';
            tasks.WhatId = premium.Id;
            tasks.ActivityDate = premium.Payment_Due_Date__c;

            System.debug('Result Task : ' + tasks);

            listTask.add(tasks);

            System.debug('Success Create Task Premium Collection.');
        }

        System.debug('Result Tasks List : ' + listTask);
               
        insert listTask;
    }

    // public static List<Premium__C> getPremiumCollection(String opptyId, String policyId){

    //     List<Premium__C> result = [SELECT Id, Insurance_Type__c, Opportunity__c, Premium_Amount__c, 
    //                                 Payment_Due_Date__c, Payment_Date__c, Followup_Result__c, Insurance_Policy__c 
    //                                 FROM Premium__c 
    //                                 WHERE Opportunity__c=:opptyId AND Insurance_Policy__c=:policyId];    

    //     System.debug('Premium Collection : '+ result);                       
        
    //     return result;
    // }
    
}