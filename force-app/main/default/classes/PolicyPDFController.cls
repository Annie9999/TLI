public class PolicyPDFController{
    
    // constructor
    // public List<InsurancePolicy> PolicyPDFController(Id srcId){
    //     return [SELECT Id, Name FROM InsurancePolicy WHERE Id = :srcId];
    // }

    // srcId get set
    public Id plcId {get;set;}
    // public Id getSrcId(){ 
    //     return srcId; 
    // }
    // public void setSrcId(Id tempId){
    //     srcId = tempId;
    // }

    // Records get set
    public List<InsurancePolicy> Records{
        get {
            Records = [SELECT Id, Name FROM InsurancePolicy WHERE Id = :plcId];
            return Records;
        }
        set;
    }

    public String PDFbody {
        get {
            ContentDocumentLink ConDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :plcId];
            ContentDocument ConDoc = [SELECT Id FROM ContentDocument WHERE Id = :ConDocLink.ContentDocumentId];
            
            
            return URL.getSalesforceBaseUrl().toExternalForm() + '/' + ConDoc.Id;
        }
        set;
    }

    public String PDFbodyBlob {
        get {
            ContentDocumentLink ConDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :plcId];
            ContentDocument ConDoc = [SELECT Id 
                FROM ContentDocument 
                WHERE Id = :ConDocLink.ContentDocumentId];
            ContentVersion ConVer = [SELECT Id, ContentDocumentId, ContentUrl, ContentBodyId, VersionNumber, OwnerId, FileType, PublishStatus, VersionData, ContentSize, Title 
                FROM ContentVersion 
                WHERE ContentDocumentId = :ConDoc.Id AND IsLatest = true];
            // Blob Body = getBlob(URL.getSalesforceBaseUrl().toExternalForm() + '/' + ConDoc.Id);
            String Body = EncodingUtil.Base64Encode(ConVer.VersionData);
            // Blob Body = EncodingUtil.Base64Decode(String.ValueOf(ConVer.VersionData));

            // Blob Body = ConVer.VersionData;

            return Body;

            // Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            //     message.setToAddresses(new String[] { 'adt@ii.co.th' });
            // List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            // Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            //     attachment.setBody(ConVer.VersionData);
            //     attachment.setFileName(ConVer.Title);
            //     attachment.setContentType(ConVer.FileType);
            //     attachments.add(attachment);
            //     message.setFileAttachments(attachments);

                // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            // return attachment;
        }
        set;
    }

    public Blob getBlob(String url){
        PageReference pageRef = new PageReference(url);
        Blob ret = pageRef.getContentAsPDF();
        return ret;
   }
    

}