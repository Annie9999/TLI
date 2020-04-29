public class ApplicationFormApexController {
    @AuraEnabled
    public static Lead getLead(string leadId) {
        System.debug('leadId' +leadId);
        Lead leadOb = new Lead();
        leadOb = [SELECT FirstName,LastName, id, Name FROM Lead where id =: leadId];
        // System.debug('opp' +leadOb);
        // System.debug('StageName: ' +leadOb.StageName);
        // System.debug('Approval_Status__c: ' +leadOb.Approval_Status__c);

        return leadOb;
    }

}