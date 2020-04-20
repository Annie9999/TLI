public class ApplicationFormApexController {
    @AuraEnabled
    public static Opportunity getOpportunity(string oppId) {
        System.debug('oppId' +oppId);
        Opportunity opp = new Opportunity();
        opp = [SELECT Account.FirstName,Account.LastName, Id, Name,StageName,Approval_Status__c FROM Opportunity where id =: oppId];
        System.debug('opp' +opp);
        System.debug('StageName: ' +opp.StageName);
        System.debug('Approval_Status__c: ' +opp.Approval_Status__c);

        return opp;
    }

}