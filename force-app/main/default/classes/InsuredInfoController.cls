public class InsuredInfoController {
	@AuraEnabled
    public static Account getInsuredInfo(String opptyId){

        List<Opportunity> listOp = [SELECT id, AccountId ,name from Opportunity WHERE id=:opptyId];

        List<Account> accList = [SELECT Id, Salutation, FirstName, LastName, Phone, Sex__pc, Race__pc, PersonBirthdate, Age__c, Email__c, Religion__pc,
            Nationality__pc, National_ID__pc, National_ID_Card_Expire_Date__pc, Weight__pc, Height__pc, BMI__pc, Occupation__pc, Marital_Status__pc,
            ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingPostalCode
            FROM Account 
            WHERE id=:listOp[0].AccountId];      
        
        Account acc = new Account();
        acc = accList[0];

        System.debug(acc);

        return acc;
    }

    @AuraEnabled
    public static Account saveInsuredInfo(Account newAcc){

        update newAcc;

        System.debug('Test After Save :'+ newAcc);

        return newAcc;
    }
}