public with sharing class searchPolicyByAgentCtrl {
    public class InsuredPolicy{
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public String policy_url {get;set;}
        @AuraEnabled
        public String insured_url {get;set;}
        @AuraEnabled
        public String agent_url {get;set;}
        @AuraEnabled
        public String policy_name {get;set;}
        @AuraEnabled
        public String insured_name {get;set;}
        @AuraEnabled
        public String gender {get;set;}
        @AuraEnabled
        public Double citizenId {get;set;}
        @AuraEnabled
        public Date birthdate {get;set;}
        @AuraEnabled
        public String insured {get;set;}
        @AuraEnabled
        public Double no {get;set;}
        @AuraEnabled
        public Datetime effectiveDate {get;set;}
        @AuraEnabled
        public String plan_name {get;set;}
        @AuraEnabled
        public String policy_payment_status {get;set;}
    }

    public searchPolicyByAgentCtrl() {

    }

    @AuraEnabled
    public static List<InsuredPolicy> search(String policyId, String keyword, String firstNameInsured, String lastNameInsured){
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
        String searchKeyword = '%' + keyword + '%';
        String searchNameInsured = '%' + firstNameInsured + '%' + lastNameInsured + '%';
        List<InsurancePolicy> lstInsurance = [SELECT Id, Name, NameInsuredId, NameInsured.Name, Gender__c, Citizen_ID__c, Birthdate__c, Insured__c, No__c, Plan_Name__c, EffectiveDate, Policy_Payment_Status__c, Agent_Client_Policy__c FROM InsurancePolicy WHERE Agent_Client_Policy__c =: policyId AND Name LIKE: searchKeyword AND NameInsured.Name LIKE: searchNameInsured LIMIT 10];
        // List<InsurancePolicy> lstInsurance = [SELECT Id, Name, NameInsuredId, NameInsured.Name, Gender__c, Citizen_ID__c, Birthdate__c, Insured__c, No__c, Plan_Name__c, EffectiveDate, Policy_Payment_Status__c, Agent_Client_Policy__c FROM InsurancePolicy WHERE Name LIKE: searchKeyword AND NameInsured.Name LIKE: searchNameInsured];

        List<InsuredPolicy> listInsureTemp = new List<InsuredPolicy>();
        for(InsurancePolicy insurance : lstInsurance){
            InsuredPolicy objInsureTemp = new InsuredPolicy();
            objInsureTemp.id = insurance.Id;
            objInsureTemp.policy_url = '/' + insurance.Id;
            objInsureTemp.insured_url = '/' + insurance.NameInsuredId;
            objInsureTemp.policy_name = insurance.Name;
            objInsureTemp.insured_name = insurance.NameInsured.Name;
            // objInsureTemp.gender = insurance.Gender__c;
            // objInsureTemp.citizenId = insurance.Citizen_ID__c;
            objInsureTemp.birthdate = insurance.Birthdate__c;
            objInsureTemp.insured = insurance.Insured__c;
            objInsureTemp.plan_name = insurance.Plan_Name__c;
            objInsureTemp.effectiveDate = insurance.EffectiveDate;
            // objInsureTemp.no = insurance.No__c;
            objInsureTemp.policy_payment_status = insurance.Policy_Payment_Status__c;
            listInsureTemp.add(objInsureTemp);
        }

        return listInsureTemp;
    }
}