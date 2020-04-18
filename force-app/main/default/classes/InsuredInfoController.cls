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
        /*acc.Id = accList[0].Id;
        acc.Salutation = accList[0].Salutation;
        acc.FirstName = accList[0].FirstName;
        acc.LastName = accList[0].LastName;
        acc.Sex__pc = accList[0].Sex__pc;
        acc.Race__pc = accList[0].Race__pc;
        acc.Birth_day__c = accList[0].Birth_day__c;
        acc.Nationality__pc = accList[0].Nationality__pc;
        acc.National_ID__pc = accList[0].National_ID__pc;
        acc.National_ID_Card_Expire_Date__pc = accList[0].National_ID_Card_Expire_Date__pc;
        acc.Weight__pc = accList[0].Weight__pc;
        acc.Height__pc = accList[0].Height__pc;
        acc.Email__c = accList[0].Email__c;
        acc.Phone = accList[0].Phone;
        acc.Occupation__pc = accList[0].Occupation__pc;
        acc.Religion__pc = accList[0].Religion__pc;
        acc.Marital_Status__pc = accList[0].Marital_Status__pc;
        acc.ShippingStreet = accList[0].ShippingStreet;
        acc.ShippingCity = accList[0].ShippingCity;
        acc.ShippingState = accList[0].ShippingState;
        acc.ShippingPostalCode = accList[0].ShippingPostalCode;
        acc.BillingStreet = accList[0].BillingStreet;
        acc.BillingCity = accList[0].BillingCity;
        acc.BillingState = accList[0].BillingState;
        acc.BillingPostalCode = accList[0].BillingPostalCode;*/

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