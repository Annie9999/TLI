public class PolicyPDFController{
    
    // constructor
    // public List<InsurancePolicy> PolicyPDFController(Id srcId){
    //     return [SELECT Id, Name FROM InsurancePolicy WHERE Id = :srcId];
    // }

    // srcId get set
    public Id srcId {get;set;}
    // public Id getSrcId(){ 
    //     return srcId; 
    // }
    // public void setSrcId(Id tempId){
    //     srcId = tempId;
    // }

    // Records get set
    public List<InsurancePolicy> Records{
        get {
            Records = [SELECT Id, Name FROM InsurancePolicy WHERE Id = :srcId];
            return Records;
        }
        set;
    }

    public String PDFBEEM {
        get {
            return URL.getSalesforceBaseUrl().toExternalForm() + '/069q0000001RyTfAAK';
        }
        set;
    }

    public Blob PDFbody {
        get {
            ContentDocument ConDoc = [SELECT Id FROM ContentDocument WHERE Id = '069q0000001RyTfAAK'];
            // ContentVersion ConVer = [SELECT Id, ContentDocumentId, ContentUrl, ContentBodyId, OwnerId, Origin FROM ContentVersion WHERE ContentDocumentId = :ConDoc.Id];
            Blob Body = getBlob(URL.getSalesforceBaseUrl().toExternalForm() + '/' + ConDoc.Id);
            return Body;
        }
        set;
    }

    public Blob getBlob(String url){
        PageReference pageRef = new PageReference(url);
        Blob ret = pageRef.getContentAsPDF();
        return ret;
   }
    

}