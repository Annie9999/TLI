public without sharing class SendQuotationTemplateController {
    public Id leadId 			{get;set;}
    public String urlOrg  		{get;set;}
    public String orgId  		{get;set;}
    public String phone  		{get;set;}
    public String logo  		{get;set;}
    public String heart  		{get;set;}
    public String death  		{get;set;}
    public String coin  		{get;set;}
    public String bed  			{get;set;}

    public SendQuotationTemplateController(){
        urlOrg = System.URL.getSalesforceBaseURL().toExternalForm();
orgId = UserInfo.getOrganizationId();
        List<Document> docList = [SELECT id, name FROM Document WHERE name in ('phone', 'logo', 'heart', 'death', 'coin', 'bed')];
        for(Document doc : docList){
            if(doc.name == 'phone'){
                phone = doc.id;
            }else if(doc.name == 'logo'){
                logo = doc.id;
            }else if(doc.name == 'heart'){
                heart = doc.id;
            }else if(doc.name == 'death'){
                death = doc.id;
            }else if(doc.name == 'coin'){
                coin = doc.id;
            }else if(doc.name == 'bed'){
                bed = doc.id;
            }
        }
    }

    public Detail getDetails(){
        System.debug('leadId '+leadId);
        Lead leadObj = new Lead();
        leadId= '00Qq000000Atm4pEAB';
        leadObj = [SELECT id,name,howtopay__c,Phone,Email,gender__c,Agee__c,Sub_productgroup__c,productgroup__c,Amount_Currency__c,totalamount__c, Date_Of_Birth__c FROM Lead where id = :leadId];
        Detail deInfo = new Detail();
        deInfo.leadObj = leadObj;
        // deInfo.age = Integer.valueOf(leadObj.Agee__c);
        System.debug(leadObj.Agee__c);
        // System.debug(deInfo.age);
        return deInfo;
    }

    public class Detail{
        public Lead leadObj {get;set;}
        public Integer age {get;set;}
    }
}