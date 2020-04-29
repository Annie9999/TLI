public class PolicyPDFController{
    
    // public String tempDataType {get
    //     {
    //         ContentDocumentLink ConDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
    //             FROM ContentDocumentLink 
    //             WHERE LinkedEntityId = :plcId LIMIT 1];
    //         ContentDocument ConDoc = [SELECT Id 
    //             FROM ContentDocument 
    //             WHERE Id = :ConDocLink.ContentDocumentId LIMIT 1];
    //         ContentVersion ConVer = [SELECT Id, ContentDocumentId, ContentUrl, ContentBodyId, VersionNumber, OwnerId, FileType, PublishStatus, VersionData, ContentSize, Title 
    //             FROM ContentVersion 
    //             WHERE ContentDocumentId = :ConDoc.Id AND IsLatest = true LIMIT 1];

    //         return ConVer.FileType;
    //     }
    //     set;
    // }

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
                WHERE LinkedEntityId = '0YTq0000000CaX5GAK' LIMIT 1];
            ContentDocument ConDoc = [SELECT Id 
                FROM ContentDocument 
                WHERE Id = :ConDocLink.ContentDocumentId LIMIT 1];
            ContentVersion ConVer = [SELECT Id, ContentDocumentId, ContentUrl, ContentBodyId, VersionNumber, OwnerId, FileType, PublishStatus, VersionData, ContentSize, Title 
                FROM ContentVersion 
                WHERE ContentDocumentId = :ConDoc.Id AND IsLatest = true LIMIT 1];
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

   public List<ContentDistribution> PublicLink {get
        {
            List<ContentDocumentLink> ConDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
                FROM ContentDocumentLink 
                // WHERE LinkedEntityId = :plcId ];
                WHERE LinkedEntityId = '0YTq0000000CaX5GAK'];
            List<Id> ListContentDocumentId = new List<Id>();
            for(ContentDocumentLink obj : ConDocLink){
                ListContentDocumentId.add(obj.ContentDocumentId);
            }
            System.debug(ListContentDocumentId);

            List<ContentDocument> ConDoc = [SELECT Id 
                FROM ContentDocument 
                WHERE Id IN :ListContentDocumentId ORDER BY CreatedDate DESC];
            
            List<ContentVersion> ConVer = [SELECT Id, ContentDocumentId, ContentUrl, ContentBodyId, VersionNumber, OwnerId, FileType, PublishStatus, VersionData, ContentSize, Title 
                FROM ContentVersion 
                WHERE ContentDocumentId IN :ListContentDocumentId AND IsLatest = true ORDER BY CreatedDate DESC];
            List<Id> ListContentVersionId = new List<Id>();
            for(ContentVersion obj : ConVer){
                ListContentVersionId.add(obj.Id);
            }
            System.debug(ListContentVersionId);
            
            List<ContentDistribution> ConDis = [SELECT Id, Owner.Name, Name, ContentVersionId, ContentDocumentId, RelatedRecordId, 
                PreferencesAllowPDFDownload, PreferencesAllowOriginalDownload, PreferencesPasswordRequired, PreferencesNotifyOnVisit, 
                PreferencesLinkLatestVersion, PreferencesAllowViewInBrowser, PreferencesExpires, PreferencesNotifyRndtnComplete, 
                DistributionPublicUrl, ContentDownloadUrl, PdfDownloadUrl 
                FROM ContentDistribution
                WHERE ContentVersionId IN :ListContentVersionId ORDER BY CreatedDate DESC];
            List<Id> ListContentDistributionContentVersionId = new List<Id>();
            for(ContentDistribution obj : ConDis){
                ListContentDistributionContentVersionId.add(obj.ContentVersionId);
            }
            System.debug(ListContentDistributionContentVersionId);
            
            List<ContentDistribution> rtnConDis = new List<ContentDistribution>();
            // String rtnLink = 'No Available Link.';
            List<ContentDistribution> InsertListConDis = new List<ContentDistribution>();
            if(ConDis.isEmpty()){
                System.debug('CASE1 : Have Not Any Link');
                for(ContentVersion objVer : ConVer){
                    ContentDistribution cd = new ContentDistribution();
                    cd.Name = objVer.Title;
                    cd.ContentVersionId = objVer.Id;
                    cd.PreferencesAllowViewInBrowser = true;
                    cd.PreferencesLinkLatestVersion = true;
                    cd.PreferencesNotifyOnVisit = false;
                    cd.PreferencesPasswordRequired = false;
                    cd.PreferencesAllowOriginalDownload = true;
                    cd.PreferencesAllowPDFDownload = true;
                    InsertListConDis.add(cd);
                }
                
                insert InsertListConDis;
                rtnConDis = InsertListConDis;
                // rtnLink = cd.DistributionPublicUrl;
                // rtnLink = ConDis[0].DistributionPublicUrl;
            }else if(ConDis.Size() == ConVer.Size()){
                System.debug('CASE2 : Existed All Link');
                rtnConDis = ConDis;
            }else if(ConDis.Size() != ConVer.Size()){
                System.debug('CASE3 : Existed Some Link');
                // Set<List<ContentDistribution>> filledSetConDis= new Set<List<ContentDistribution>>();
                List<ContentDistribution> InsertListConDis_NotExist = new List<ContentDistribution>();
                for(ContentVersion objVer :ConVer){
                    if(ListContentDistributionContentVersionId.contains(objVer.Id)){
                        System.debug('CASE3 : contains');
                        for(ContentDistribution objDis : ConDis){
                            if(objDis.ContentVersionId == objVer.Id){
                                rtnConDis.add(objDis);
                                break;
                            }
                        }
                    }else if(!ListContentDistributionContentVersionId.contains(objVer.Id)){
                        System.debug('CASE3 : not contains');
                        
                        // for(ContentVersion objVer : ConVer){
                            // if(!ListContentDistributionContentVersionId.contains(objVer.Id)){
                                ContentDistribution cd = new ContentDistribution();
                                    cd.Name = objVer.Title;
                                    cd.ContentVersionId = objVer.Id;
                                    cd.PreferencesAllowViewInBrowser = true;
                                    cd.PreferencesLinkLatestVersion = true;
                                    cd.PreferencesNotifyOnVisit = false;
                                    cd.PreferencesPasswordRequired = false;
                                    cd.PreferencesAllowOriginalDownload = true;
                                    // cd.PreferencesAllowPDFDownload = true;
                                    InsertListConDis_NotExist.add(cd);
                                    System.debug('InsertListConDis_NotExist : ' + InsertListConDis_NotExist);
                            // }
                        // }
                        // filledSetConDis.add(InsertListConDis_NotExist);
                        // System.debug('filledSetConDis : ' + filledSetConDis);
                    }
                }
                insert InsertListConDis_NotExist;
                System.debug('After insert : ' + InsertListConDis_NotExist);
                rtnConDis.addAll(InsertListConDis_NotExist);

                // List<ContentDistribution> InsertedListConDis_NotExist = [SELECT Id, Owner.Name, Name, ContentVersionId, ContentDocumentId, RelatedRecordId, 
                // PreferencesAllowPDFDownload, PreferencesAllowOriginalDownload, PreferencesPasswordRequired, PreferencesNotifyOnVisit, 
                // PreferencesLinkLatestVersion, PreferencesAllowViewInBrowser, PreferencesExpires, PreferencesNotifyRndtnComplete, 
                // DistributionPublicUrl, ContentDownloadUrl, PdfDownloadUrl 
                // FROM ContentDistribution
                // WHERE ContentVersionId IN :ListContentVersionId ORDER BY CreatedDate DESC];
                // System.debug('After insert : ' + InsertedListConDis_NotExist);
                // rtnConDis.addAll(InsertedListConDis_NotExist);

                // for(ContentDistribution objDis :ConDis){
                //     if(ListContentVersionId.contains(objDis.ContentVersionId)){
                //         System.debug('CASE3 : contains');
                //         rtnConDis.add(objDis);
                //     }else if(!ListContentVersionId.contains(objDis.ContentVersionId)){
                //         System.debug('CASE3 : not contains');
                //         List<ContentDistribution> InsertListConDis_NotExist = new List<ContentDistribution>();
                //         for(ContentVersion objVer : ConVer){
                //             if(!ListContentDistributionContentVersionId.contains(objVer.Id)){
                //                 ContentDistribution cd = new ContentDistribution();
                //                     cd.Name = objVer.Title;
                //                     cd.ContentVersionId = objVer.Id;
                //                     cd.PreferencesAllowViewInBrowser = true;
                //                     cd.PreferencesLinkLatestVersion = true;
                //                     cd.PreferencesNotifyOnVisit = false;
                //                     cd.PreferencesPasswordRequired = false;
                //                     cd.PreferencesAllowOriginalDownload = true;
                //                     cd.PreferencesAllowPDFDownload = true;
                //                     InsertListConDis_NotExist.add(cd);
                //                     System.debug('InsertListConDis_NotExist : ' + InsertListConDis_NotExist);
                //             }
                //         }
                //         filledSetConDis.add(InsertListConDis_NotExist);
                //         System.debug('filledSetConDis : ' + filledSetConDis);
                //     }
                // }
                // List<ContentDistribution> InsertListCondis_All = new List<ContentDistribution>();
                // for(List<ContentDistribution> obj : filledSetConDis){
                //     InsertListCondis_All.addAll(obj);
                // }
                // insert InsertListCondis_All;
                // rtnConDis.addAll(InsertListCondis_All);
            }
            
            System.debug('rtnConDis size: ' + rtnConDis.Size());
            return rtnConDis;
        }
        set;
    }

   
    

}