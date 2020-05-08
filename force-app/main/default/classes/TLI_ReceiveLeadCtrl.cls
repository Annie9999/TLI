public with sharing class TLI_ReceiveLeadCtrl {
    
    @AuraEnabled
    public static String ReceiveLead(Id LeadId) {
        try{
            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='LMS Business Hours'];
            Datetime now = Datetime.now();
            Lead lead = [SELECT Id, RecordType.Name, SLA__c FROM Lead WHERE Id =: LeadId LIMIT 1];
            if(lead.RecordType.Name == 'สนใจทำประกันผ่านตัวแทน'){
                lead.SLA__c = BusinessHours.addGmt(bh.Id, lead.SLA__c, 15*9* 60 * 60 * 1000L);
            }else if(lead.RecordType.Name == 'สนใจเป็นตัวแทน') {
                lead.SLA__c = BusinessHours.addGmt(bh.Id, lead.SLA__c, 7*9* 60 * 60 * 1000L);
            }
            lead.Status = 'ยืนยันการรับงาน';
            System.debug('lead= '+lead);
            update lead;
            return lead.Status;
        }catch(Exception e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static string ReAssign(Id LeadId){
        try {
            Lead lead = [SELECT Id,Status,OwnerId, ACC_owner__c FROM Lead WHERE Id =: LeadId];
            lead.Status = 'ส่งคืนผู้มุ่งหวัง';
            System.Debug('Acc Owner= '+lead.ACC_owner__c);
            lead.OwnerId = lead.ACC_owner__c;
            update lead;
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
        
    }

    @AuraEnabled
    public static string getStatus(Id leadId){
        Lead leadObj = [SELECT id,Status
                        FROM Lead
                        WHERE id = : leadId];
        return leadObj.Status;     
        
    }
}