public class ApplicationFormApexController {
    @AuraEnabled
    public static Opportunity getOpportunity(string oppId) {
        System.debug('oppId' +oppId);
        Opportunity opp = new Opportunity();
        opp = [SELECT Account.FirstName,Account.LastName, Id, Name FROM Opportunity where id =: oppId];
        System.debug('opp' +opp);
        return opp;
    }

}