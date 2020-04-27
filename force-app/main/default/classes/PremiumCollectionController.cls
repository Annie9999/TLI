public class PremiumCollectionController {

    public static List<Premium__C> getPremiumCollection(String opptyId, String policyId){

        List<Premium__C> result = [SELECT Id, Insurance_Type__c, Opportunity__c, Premium_Amount__c, 
                                    Payment_Due_Date__c, Payment_Date__c, Followup_Result__c, Insurance_Policy__c 
                                    FROM Premium__c 
                                    WHERE Opportunity__c=:opptyId AND Insurance_Policy__c=:policyId];    

        System.debug('Premium Collection : '+ result);                       
        
        return result;
    }

    @InvocableMethod(label='Create Premium Collection')
    public static void createPremiumCollection(List<Opportunity> opportunity){
        
        String opptyId = opportunity[0].Id;

        Opportunity opp = [SELECT Id, AccountId, Amount, productgroup__c, Sub_productgroup__c, Payment_Mode__c
                            FROM Opportunity 
                            WHERE id=:opptyId];    

        InsurancePolicy poli = [SELECT Id, Name, PremiumAmount, PremiumFrequency, Status, PaymentDueDate, SourceOpportunityId 
                                    FROM InsurancePolicy
                                    WHERE SourceOpportunityId =:opptyId 
                                    ORDER BY LastModifiedDate DESC LIMIT 1];  

        System.debug('Opportunity :'+ opp);
        System.debug('InsurancePolicy :'+ poli);

        Date dueDate = Date.today();
        List<Premium__C> listPremium = new List<Premium__C>();
        List<Task> listTask = new List<Task>();

        if (opp.Payment_Mode__c == 'รายเดือน') {
            for (Integer i = 1; i <= 11; i++) {

                // Create Premium Collection
                Premium__C pc = new Premium__C();
                pc.Name = 'Premium Collection #' + i;
                pc.Insurance_Policy__c = poli.Id;
                pc.Insurance_Type__c = 'ปีแรก';
                pc.Followup_Result__c = 'Wait';
                pc.Opportunity__c = opp.Id;
                pc.Premium_Amount__c = Double.valueOf(opp.amount);
                pc.Payment_Due_Date__c = dueDate.addMonths(1*i);
                pc.Payment_Date__c = dueDate.addMonths(1*i).addDays(5);

                System.debug('Result Collection : ' + pc);

                listPremium.add(pc);

                System.debug('Success Create Premium Collection.');
            }
        } else if(opp.Payment_Mode__c == 'ราย 3 เดือน'){
            for (Integer i = 1; i <= 3; i++) {
                Premium__C pc = new Premium__C();
                pc.Name = 'Premium Collection #' + i;
                pc.Insurance_Policy__c = poli.Id;
                pc.Insurance_Type__c = 'ปีแรก';
                pc.Followup_Result__c = 'Wait';
                pc.Opportunity__c = opp.Id;
                pc.Premium_Amount__c = Double.valueOf(opp.amount);
                pc.Payment_Due_Date__c = dueDate.addMonths(3*i);
                pc.Payment_Date__c = dueDate.addMonths(3*i).addDays(5);

                System.debug('Result Collection : ' + pc);

                listPremium.add(pc);

                System.debug('Success Create Premium Collection.');
            }
        } else if(opp.Payment_Mode__c == 'ราย 6 เดือน'){
                Integer i = 1;
                Premium__C pc = new Premium__C();
                pc.Name = 'Premium Collection #' + i;
                pc.Insurance_Policy__c = poli.Id;
                pc.Insurance_Type__c = 'ปีแรก';
                pc.Followup_Result__c = 'Wait';
                pc.Opportunity__c = opp.Id;
                pc.Premium_Amount__c = Double.valueOf(opp.amount);
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
    
}