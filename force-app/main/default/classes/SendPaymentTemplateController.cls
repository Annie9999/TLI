public class SendPaymentTemplateController {
    public Id oppId {get;set;}

   

    public PaymentDetail getPaymentDetails(){
        System.debug('oppId '+oppId);
        Opportunity opp = new Opportunity();
        opp = [SELECT id,AccountId,productgroup__c,name,Payment_Mode__c,Amount, Date_Of_Birth__c, gender__c FROM Opportunity where id =: oppId];
        Account acc = new Account();
        acc = [SELECT id, name,Age__c,PersonEmail,Sex__pc,PersonBirthdate,FirstName,LastName,Phone  FROM Account where id =: opp.AccountId];
        // OpportunityLineItem opptyLine = new OpportunityLineItem();
        // opptyLine = [SELECT Id, OpportunityId, PricebookEntryId, Product2Id,Product2.Name, ProductCode, Name, TotalPrice, Quantity FROM OpportunityLineItem where OpportunityId =:oppId];

        PaymentDetail deInfo = new PaymentDetail();
        deInfo.oppty = opp;
        deInfo.acc = acc;
        deInfo.age = Integer.valueOf(acc.Age__c);
        return deInfo;
    }

    public class PaymentDetail{
        public Account acc {get;set;}
        public Opportunity oppty {get;set;}
        public Integer age {get;set;}
      

    }
    
}