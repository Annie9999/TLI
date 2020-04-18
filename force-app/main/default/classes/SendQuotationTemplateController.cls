public class SendQuotationTemplateController {
    public Id oppId {get;set;}

    public SendQuotationTemplateController(){
        // System.debug('oppId '+oppId);
    }

    public Detail getDetails(){
        System.debug('oppId '+oppId);
        Opportunity opp = new Opportunity();
        opp = [SELECT id,AccountId,productgroup__c,name,Payment_Mode__c,Amount, Date_Of_Birth__c, gender__c FROM Opportunity where id =: oppId];
        Account acc = new Account();
        acc = [SELECT id, name,Age__c,PersonEmail,Sex__pc,PersonBirthdate,FirstName,LastName FROM Account where id =: opp.AccountId];
        // OpportunityLineItem opptyLine = new OpportunityLineItem();
        // opptyLine = [SELECT Id, OpportunityId, PricebookEntryId, Product2Id,Product2.Name, ProductCode, Name, TotalPrice, Quantity FROM OpportunityLineItem where OpportunityId =:oppId];

        Detail deInfo = new Detail();
        deInfo.oppty = opp;
        deInfo.acc = acc;
        deInfo.age = Integer.valueOf(acc.Age__c);
        return deInfo;
    }

    public class Detail{
        public Account acc {get;set;}
        public Opportunity oppty {get;set;}
        public Integer age {get;set;}
    }
}