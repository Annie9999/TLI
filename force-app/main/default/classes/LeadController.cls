public class LeadController {
    
    
    
    @AuraEnabled
    public static Lead getLead(string leadId) {
        System.debug('leadId: ' +leadId);
        Lead leads = [SELECT Id,Name,FirstName,LastName, Account__c FROM Lead WHERE Id =: leadId limit 1];
        System.debug('leads: ' +leads);
        return leads;
        
    }
    
    @AuraEnabled
    public static Id saveNewLead(Lead leads) {
        System.debug('leads: ' +leads);
        
        List<Lead>  leadList = [SELECT Id,Account__c,Name,FirstName,LastName,age__c,gender__c,Email,Phone ,Date_Of_Birth__c  FROM Lead WHERE id=:leads.Id];
        
        Lead newLead = new Lead();
        newLead.Account__c = leadList[0].Account__c;
        newLead.FirstName = leadList[0].FirstName;
        newLead.LastName = leadList[0].LastName + 'สนใจอีกครั้ง' ;
        newLead.age__c = leadList[0].age__c;
        newLead.gender__c = leadList[0].gender__c;
        newLead.Email = leadList[0].Email;
        newLead.Phone = leadList[0].Phone;
        newLead.Date_Of_Birth__c = leadList[0].Date_Of_Birth__c;
        newLead.LeadSource = 'เสนอผลิตภัณฑ์ใหม่ให้ผู้มุ่งหวัง';
        insert newLead;
        System.debug('newLead: ' +newLead);
        return newLead.Id;
        
        
        
        
        
        
    }
    
}