public class INS_PolicyListController {
    @AuraEnabled
    public static List<InsurancePolicy> getPolicies(String accountId) {
        List<InsurancePolicy> policies = new List<InsurancePolicy>();
        
        if (isNullOrEmpty(accountId)) {
            /* Attempt to retreive Account Id from the current User */
            User user = [ SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId() ];
            accountId = user.AccountId;
        }
        
        System.Debug(accountId);
        
        if (!isNullOrEmpty(accountId)) {
            return [ SELECT Id, Name, toLabel(PolicyType), EffectiveDate, ExpirationDate,
                            FORMAT(PremiumAmount), PremiumFrequency, Policy_Term__c 
                    FROM InsurancePolicy
                    WHERE ( NameInsuredId = :accountId OR Producer.AccountId = :accountId ) AND
                    Status  Like 'In Force%'
                    ORDER BY Name ];
        }
        
        return policies;
    }
    
    @AuraEnabled
    public static List<InsurancePolicy> getPendingPolicies(String accountId) {
        List<InsurancePolicy> policies = new List<InsurancePolicy>();
        
        if (isNullOrEmpty(accountId)) {
            /* Attempt to retreive Account Id from the current User */
            User user = [ SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId() ];
            accountId = user.AccountId;
        }
        
        System.Debug(accountId);
        
        if (!isNullOrEmpty(accountId)) {
            return [ SELECT Id, Name, PolicyType, EffectiveDate, ExpirationDate,
                            FORMAT(PremiumAmount) , PremiumFrequency, Policy_Term__c 
                    FROM InsurancePolicy 
                    WHERE ( NameInsuredId = :accountId OR Producer.AccountId = :accountId ) AND
                    Status = 'Initial'
                    ORDER BY Name ];
        }
        
        return policies;
    }
    
    @AuraEnabled
    public static InsurancePolicy getPolicy(String policyId) {
        return [ SELECT Id, Name, PolicyType, EffectiveDate, ExpirationDate,
                PremiumAmount, PremiumFrequency, Policy_Term__c 
                FROM InsurancePolicy 
                WHERE Id = :policyId ];
    }
    
    private static Boolean isNullOrEmpty(String str) {
        return str == NULL || str == '';
    }
}