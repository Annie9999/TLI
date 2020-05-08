public without sharing class Utility {

    public static String createCase(String subject, String description, String priority, String leadId, String ownerId, String recordTypeName){
        Case cs = new Case();
        cs.Subject = subject;
        cs.Status = 'open';
        cs.Description = description;
        cs.Priority = priority;
        cs.Lead__c = leadId;
        cs.OwnerId = ownerId;
        cs.Type = 'Internal Process';
        if(recordTypeName != ''){
            cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }
        System.debug(cs);
        
        insert cs;
        
        return 'Add Case Success';
    }

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
	
    public static void AttachPDF(String title, String recordId){
        List<ContentVersion> contentList = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Title =: title];
        if(contentList.size() > 0){
			ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            conVer.PathOnClient = title + '.PDF';
            conVer.Title = title;
            conVer.VersionData = contentList[0].VersionData; 
            conVer.IsMajorVersion = false;
            insert conVer;
            
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recordId;
            conDocLink.ContentDocumentId = conDoc;
            conDocLink.shareType = 'V';
            system.debug(conDocLink);
            insert conDocLink;
        }
    }
    @InvocableMethod
    public static void convertLead(List<Lead> leads){
        system.debug('leads :'+leads);
        List<Lead> leadList = [select Id, Name,OwnerId,productgroup__c, Email,Amount_Currency__c,howtopay__c   from Lead where id = :leads[0].id];
        Lead myLead = new Lead();
        myLead = leadList[0];
        String OwnerStr = myLead.OwnerId;
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(myLead.id);
        if(OwnerStr.startsWith('00G')){
            lc.setOwnerId(UserInfo.getUserId());
        }
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(TRUE);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        system.debug('lcr.getAccountId() '+lcr.getAccountId());
        Account acc = new Account();
            acc.id = lcr.getAccountId();
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account Existing').getRecordTypeId();
        update acc;
        
        Integer randomNumber = Integer.valueof((Math.random() * 100));
		System.debug('randomNumber  is '+randomNumber);
        InsurancePolicy policy = new InsurancePolicy();
        policy.Name = '58000'+randomNumber;
        policy.NameInsuredId = acc.Id;
        policy.PremiumAmount = myLead.Amount_Currency__c;
        policy.PremiumFrequency  = myLead.howtopay__c;
        policy.PolicyType  = 'Life';

        // policy.Code_insurance__c = leadList[0].productgroup__c;
        policy.Mature_Date__c = system.today().addYears(1);
        policy.RenewalDate = system.today().addYears(1);
        policy.Source_Lead__c = myLead.id;

        insert policy;
            
        System.assert(lcr.isSuccess());
    }
}