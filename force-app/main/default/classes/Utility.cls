public class Utility {
    //@AuraEnabled
    public static String createCase(String subject, String description, String priority, String accountId, 
                                    String opptyId, String ownerId, String recordTypeName){
        Case cs = new Case();

        cs.Subject = subject;
        cs.Status = 'open';
        cs.Description = description;
        cs.Priority = priority;
        cs.AccountId = accountId;
        cs.Opportunity__c = opptyId;
        if(recordTypeName != ''){
            cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }
        cs.OwnerId = ownerId;
        cs.Type = 'Internal Process';
        
        System.debug(cs);
        
        insert cs;
        
        return 'Add Case Success';
    }
    
    public static void sendEmail(Id leadId,String templateEmail,boolean chkAttach){

        List<Lead> leadList = [select Id, Name, Email from Lead where id = :leadId];
        system.debug('leadList '+leadList);
        string email = leadList[0].Email;
        // string email = 'ntw@ii.co.th';
        System.debug(leadId);
        System.debug(templateEmail);
        System.debug(chkAttach);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(UserInfo.getUserId()); 
            message.setSenderDisplayName('ไทยประกันชีวิต');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false); 
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =:templateEmail];
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(leadId); //This is important for the merge fields in template to work
            message.toAddresses = new String[] {email};
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            if(chkAttach){
                StaticResource sr = [Select  Name, Id, Body From StaticResource WHERE Name = 'pdfForDemo'];
                     Blob tempBlob = sr.Body;
                     Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setBody(tempBlob);
                        efa.setFileName('3online_E_policy_9900002485_ThaiLife_Logo.pdf');
                        message.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            }
           
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

            if (results[0].success){
                System.debug('The email was sent successfully');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }
    }
}