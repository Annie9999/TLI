public class SendPaymentTemplateController {
    public Id leadId {get;set;}


   

    public PaymentDetail getPaymentDetails(){
        System.debug('leadId '+leadId);
        Lead leadObj = new Lead();
        leadObj = [SELECT id,name,howtopay__c,Phone,Email,gender__c,age__c,Sub_productgroup__c,productgroup__c,Amount_Currency__c,totalamount__c, Date_Of_Birth__c FROM Lead where id = :leadId];
        PaymentDetail deInfo = new PaymentDetail();
        deInfo.leadObj = leadObj;
        deInfo.age = Integer.valueOf(leadObj.age__c);
        return deInfo;
    }

    public class PaymentDetail{
        public Lead leadObj {get;set;}
        public Integer age {get;set;}
      

    }
    
}