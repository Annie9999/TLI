public class InsuredInfoController {
	// @AuraEnabled
    // public static Account getInsuredInfo(String opptyId){

    //     List<Opportunity> listOp = [SELECT id, AccountId ,name from Opportunity WHERE id=:opptyId];

    //     List<Account> accList = [SELECT Id, Salutation, FirstName, LastName, Phone, Sex__pc, Race__pc, PersonBirthdate, Age__c, PersonEmail, Religion__pc,
    //         Nationality__pc, National_ID__pc, National_ID_Card_Expire_Date__pc, Weight__pc, Height__pc, BMI__pc, Occupation__pc, Marital_Status__pc,
    //         ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingPostalCode
    //         FROM Account 
    //         WHERE id=:listOp[0].AccountId];      
        
    //     Account acc = new Account();
    //     acc = accList[0];

    //     System.debug(acc);

    //     return acc;
    // }

    // @AuraEnabled
    // public static Account saveInsuredInfo(Account newAcc){

    //     update newAcc;

    //     System.debug('Test After Save :'+ newAcc);

    //     return newAcc;
    // }

    @AuraEnabled
    public static Lead getInsuredInfo(String leadId){
        Lead ld = new Lead();

        ld = [SELECT Id, Salutation, FirstName, LastName, Email, Phone, Gender__c, Race__c, Nationality__c, Religion__c, 
        Date_Of_Birth__c, Agee__c, Marital_Status__c, Height__c, Weight__c, BMI__c, 
        Street, City, State, PostalCode, Street__c, City__c, State__c, PostalCode__c, 
        National_ID__c, National_ID_Card_Expire_Date__c, Occupation__c
        FROM Lead WHERE id=:leadId];

        System.debug(ld);

        return ld;
    }

    @AuraEnabled
    public static Lead saveInsuredInfo(Lead ld){

        update ld;

        System.debug('Result After Save :'+ ld);

        return ld;
    }
}