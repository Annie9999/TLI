public with sharing class SendEPolicyTemplateController {
	public Id oppId {get;set;}
    
    public SendEPolicyTemplateController(){
        //this.oppId = '006q000000KWE9XAAX';
    }

    public DisplayEPolicyTemplate getOpportunity() {
        System.debug('oppId' +this.oppId);
        Opportunity opp = new Opportunity();
        opp = [SELECT id,AccountId, name, Date_Of_Birth__c, gender__c,Account.Id, Account.Name, Account.LastName, Account.FirstName, Account.Age__c, Account.PersonEmail, Account.Sex__pc FROM Opportunity where id =: this.oppId];
        //Account acc = new Account();
        //acc = [SELECT Id, Name, LastName, FirstName, Age__c, PersonEmail, Sex__pc FROM Account where id =: opp.AccountId];
        System.debug('oppId' +opp);

        DisplayEPolicyTemplate data = new DisplayEPolicyTemplate();
        data.name = opp.Account.Name;
        data.gender = opp.Account.Sex__pc;
        data.effectiveDate = Datetime.now().format('dd MMMM yyyy');
        data.insurancePolicyCode = '9900002485';

        
        /*res.opptyObj = opp;
        res.accObj = acc;
        res.mapDependent = getDependentMap();

        System.debug('res.opptyObj '+res.opptyObj);
        System.debug('res.accObj '+res.accObj);
        System.debug('res.mapDependent '+res.mapDependent);*/
        return data;
    }
    
    public void sendEPolicy() {
        List<Opportunity> opptyList = [select Id, Name, Account.PersonEmail from Opportunity where id = :this.oppId];
        string email = opptyList[0].Account.PersonEmail;
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(UserInfo.getUserId()); 
            message.setSenderDisplayName('ไทยประกันชีวิต');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false); 
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'SendEPolicy'];
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(this.oppId); //This is important for the merge fields in template to work
            message.toAddresses = new String[] {email};
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            StaticResource sr = [Select  Name, Id, Body From StaticResource WHERE Name = 'pdfForDemo'];
                 Blob tempBlob = sr.Body;
                 Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setBody(tempBlob);
                    efa.setFileName('3online_E_policy_9900002485_ThaiLife_Logo.pdf');
                    message.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success){
                System.debug('The email was sent successfully');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }
    }
    
    @InvocableMethod
    public static void execute (List<Opportunity> opportunity) {
    	Utility.sendEmail(opportunity[0].Id, 'SendEPolicy',true);
  	}
    
    @AuraEnabled
    public static List<Opportunity> getOpportunity(Id insurancePolicyId){
        List<InsurancePolicy> vInsurancePolicyItems = [
            SELECT Id, Name, SourceOpportunityId FROM InsurancePolicy where Id =:insurancePolicyId
        ];
        
        List<Opportunity> vOpportunityItems = [SELECT id,AccountId, name, Date_Of_Birth__c, gender__c,Account.Id, Account.Name, Account.LastName, Account.FirstName, Account.Age__c, Account.PersonEmail, Account.Sex__pc FROM Opportunity where id =: vInsurancePolicyItems[0].SourceOpportunityId ];
        return vOpportunityItems;
    }
    
    @AuraEnabled
    public static String executeOnButtonClick (Id opportunityId) {
        try{
            Utility.sendEmail(opportunityId, 'SendEPolicy',true);
            return 'success';
        }catch(Exception ex){
            return 'failed';
        }
      }
      
    public class DisplayEPolicyTemplate{
        public String name {get;set;}
        public Integer age {get;set;}
        public String gender {get;set;}
        public String insurancePolicyCode{get;set;}
        public String effectiveDate{get;set;}
    }
}