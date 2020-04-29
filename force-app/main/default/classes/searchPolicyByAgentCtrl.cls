public with sharing class searchPolicyByAgentCtrl {
    public searchPolicyByAgentCtrl() {

    }

    @AuraEnabled
    public static List<InsurancePolicy> search(String keyword, String firstNameInsured, String lastNameInsured){
        System.debug('keyword : '+keyword);
        System.debug('firstNameInsured : '+firstNameInsured);
        System.debug('lastNameInsured : '+lastNameInsured);

        if(keyword == null){
            keyword = '';
        }
        if(firstNameInsured == null){
            firstNameInsured = '';
        }
        if(lastNameInsured == null){
            lastNameInsured = '';
        }
        String searchKeyword = keyword + '%';
        String searchNameInsured = firstNameInsured + '%' + lastNameInsured;
        List<InsurancePolicy> lstInsurance = [SELECT Id, Name, NameInsured.Name, Gender__c, Citizen_ID__c, Birthdate__c, Insured__c, No__c FROM InsurancePolicy WHERE Name LIKE: searchKeyword AND NameInsured.Name LIKE: searchNameInsured LIMIT 10];
        return lstInsurance;
    }
}