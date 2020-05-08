public with sharing class AddSLATimeCtrl {
    
    @AuraEnabled
    public static string AddSLATime(Id LeadId){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='LMS Business Hours'];
        Datetime now = Datetime.now();
        // Integer slaHours = 2;

        
        try{
            Lead lead = [SELECT Id, RecordType.Name, SLA__c FROM Lead WHERE Id =: LeadId LIMIT 1];
            if(lead.RecordType.Name == 'สนใจทำประกันผ่านตัวแทน'){
                // lead.SLA__C = Datetime.valueOf(lead.SLA__c).add;
                lead.SLA__c = BusinessHours.addGmt(bh.Id, lead.SLA__c, 10*9* 60 * 60 * 1000L);
            }else if(lead.RecordType.Name == 'สนใจเป็นตัวแทน') {
                lead.SLA__c = BusinessHours.addGmt(bh.Id, lead.SLA__c, 3*9* 60 * 60 * 1000L);
            }
            update lead;
            return 'success';
        }catch(Exception e){
            return e.getMessage();
        }
        
    }
    
    @AuraEnabled
    public static Lead getStatus(Id leadId){
        Lead leadObj = [SELECT id,Status,RecordType.Name
                        FROM Lead
                        WHERE id = : leadId];
        return leadObj;     
        
    }
    
}