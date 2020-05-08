public without sharing class LeadDMAttachFile {
	@InvocableMethod
    public static void AttachFile(List<Lead> leadList){
        System.debug('AttachFile : ' + leadList);
        
        Lead leadObj = [SELECT Id, name, Sub_Status__c  FROM Lead WHERE Id =: leadList[0].id];

        String title = 'NCPAY';
        if(leadObj.Sub_Status__c == 'ส่งคำขอเพื่ออนุมัติกรมธรรม์' ){
            title = 'YesFile';
        }else if (leadObj.Sub_Status__c == 'ส่งเรื่องถึง UW'){
            title = 'NCPAY';
        }
        
        Utility.AttachPDF(title, leadObj.Id);
    }
}