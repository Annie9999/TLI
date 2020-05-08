public class AcceptRejectMockupController {
    @AuraEnabled
    public static Lead uwApprove(String recordId){
        Lead ld = [SELECT Id, Sub_Status__c FROM Lead WHERE Id=:recordId];

        ld.Sub_Status__c = 'ส่งคำขอเพื่ออนุมัติกรมธรรม์';

        update ld;

        System.debug(ld);

        return ld;
    }

    @AuraEnabled
    public static Lead uwReject(String recordId){
        Lead ld = [SELECT Id, Sub_Status__c FROM Lead WHERE Id=:recordId];
        
        ld.Sub_Status__c = 'UW ปฏิเสธ';

        update ld;

        System.debug(ld);

        return ld;
    }

    @AuraEnabled
    public static Lead nbApprove(String recordId){
        Lead ld = [SELECT Id, Sub_Status__c FROM Lead WHERE Id=:recordId];
        
        ld.Sub_Status__c = 'อนุมัติกรมธรรม์เรียบร้อย';

        update ld;

        System.debug(ld);

        return ld;
    }

    @AuraEnabled
    public static Lead nbReject(String recordId){
        Lead ld = [SELECT Id, Sub_Status__c FROM Lead WHERE Id=:recordId];
        
        ld.Sub_Status__c = 'ปฏิเสธการออกกรมธรรม์';

        update ld;

        System.debug(ld);

        return ld;
    }
}