public without sharing class TLI_ModalLogACallCtrl {

    @AuraEnabled
    public static Lead transferRecordTypeToDM(String leadId){
        Group gtp = [SELECT Id FROM Group WHERE Name = 'Lead DM' and Type = 'Queue' LIMIT 1];
        Lead lead = new Lead();
        lead.Id = leadId;
        lead.Status = 'ส่งต่อผู้มุ่งหวัง';
        lead.TLI_Division_Create__c = 'DM';
        lead.OwnerId = gtp.Id ;
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('สนใจทำประกันผ่านโทรศัพท์').getRecordTypeId(); 
        update lead;
        return lead;
    }

    @AuraEnabled
    public static Lead sendMailByTemplate(String leadId){
        Lead leadObj = [SELECT id,Email FROM Lead WHERE id=:leadId];
        EmailTemplate et = [SELECT Id,Subject,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName ='ACC_LMS'];
        List<string> toAddress = new List<string>();
        toAddress.add(leadObj.Email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // mail.setWhoId(leadObj.Id);
        mail.setTemplateId(et.Id);
        mail.setToAddresses(toAddress);
        // mail.setSubject(et.Subject);
        mail.setSenderDisplayName('Company Support'); 
        mail.setTargetObjectId(leadObj.Id);
        // mail.setHtmlBody(et.HtmlValue);
        // mail.setTreatBodiesAsTemplate(true);
        // mail.setWhoId(leadObj.Id);
        
        mail.setSaveAsActivity(true);
        mail.setUseSignature(false);
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
        
        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
           
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }
            return leadObj;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
            // return null;

        }
    }

   
}