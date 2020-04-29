public class SendQuotationTemplateController {
    public Id leadId {get;set;}

    public SendQuotationTemplateController(){
    }

    public Detail getDetails(){
        System.debug('leadId '+leadId);
        Lead leadObj = new Lead();
        leadObj = [SELECT id,name,howtopay__c,Phone,Email,gender__c,age__c,Sub_productgroup__c,productgroup__c,Amount_Currency__c,totalamount__c, Date_Of_Birth__c FROM Lead where id = :leadId];
        Detail deInfo = new Detail();
        deInfo.leadObj = leadObj;
        deInfo.age = Integer.valueOf(leadObj.age__c);
        return deInfo;
    }

    public class Detail{
        public Lead leadObj {get;set;}
        public Integer age {get;set;}
    }
}