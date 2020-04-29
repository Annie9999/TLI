public without sharing class beneficiaryController {

    @AuraEnabled
    public static void createBeneficiary(String benefList, String leadId){
        System.debug('benefList: '+benefList);
        System.debug('leadId: ' +leadId);
        System.debug([SELECT Name FROM Lead WHERE Id = :leadId]);
        
        Lead leads = [SELECT Id, Account__c FROM Lead WHERE Id = :leadId];
        List<Map<String, String>> data = (List<Map<String, String>>)JSON.deserializeStrict(benefList, List<Map<String, String>>.class);
        
        List<Contact> newContacts = new List<Contact>();
        for(Map<String, String> m : data){
            String birthdate_string = m.get('Birthdate');
            Date birthdate_date = (Date)JSON.deserialize('"' + birthdate_string + '"', Date.class);
            System.debug('Birthdate: '+birthdate_date);

            Contact c = new Contact(
                Salutation=m.get('Salutation'),
                FirstName=m.get('FirstName'),
                LastName=m.get('LastName'),
                Birthdate=birthdate_date,
                National_ID__c='1234567891234'
            );
            newContacts.add(c);
        }
        System.debug(newContacts);
        insert newContacts;


        List<Contact_Role__c> newOcr = new List<Contact_Role__c>();
        for(Integer i = 0;i < newContacts.size();i++){
            System.debug('Percent ' +decimal.valueOf(data[i].get('Percentage_Beneficiary__c')));
                Contact_Role__c ocr = new Contact_Role__c(
                Relationship__c = data[i].get('Relationship__c'),
                Percentage_Beneficiary__c = decimal.valueOf(data[i].get('Percentage_Beneficiary__c'))
            );
            System.debug('Account '+leads.Account__c);

            ocr.Contact__c = newContacts[i].Id;
            ocr.Lead__c = leads.Id;
            ocr.Role__c = 'ผู้รับผลประโยชน์';
            System.debug('Contact: '+ocr.Contact__c);
            System.debug('Lead: '+ocr.Lead__c);
            newOcr.add(ocr);
            
        }
        System.debug(newOcr);
        insert newOcr;


      /*  Opportunity opty = [SELECT Id, AccountId FROM Opportunity WHERE Id = :oppId];
        List<Map<String, String>> data = (List<Map<String, String>>)JSON.deserializeStrict(benefList, List<Map<String, String>>.class);

        List<Contact> newContacts = new List<Contact>();
        List<OpportunityContactRole> newOcr = new List<OpportunityContactRole>();*/

        //Put contacts into list
        /*for(Map<String, String> m : data){

            String birthdate_string = m.get('Birthdate');
            Date birthdate_date = (Date)JSON.deserialize('"' + birthdate_string + '"', Date.class);

            System.debug(birthdate_date);

            Contact c = new Contact(
                Salutation=m.get('Salutation'),
                FirstName=m.get('FirstName'),
                LastName=m.get('LastName'),
                Birthdate=birthdate_date,
                National_ID__c='1234567891234'
            );

            /*System.debug(m.get('Relationship__c'));
            System.debug(m.get('Percentage_Beneficiary__c'));

            OpportunityContactRole ocr = new OpportunityContactRole(
                Relationship__c: m.get('Relationship__c'),
                Percentage_Beneficiary__c: Percentage_Beneficiary__c
            );
            newContacts.add(c);
        }
        
        System.debug(newContacts);
        insert newContacts;*/

        
        //Put OpportunityContactRole into list
        //data[i].get('Relationship__c')
       /* for(Integer i = 0;i < newContacts.size();i++){
            System.debug('Percent ' +decimal.valueOf(data[i].get('Percentage_Beneficiary__c')));
            OpportunityContactRole ocr = new OpportunityContactRole(
                Relationship__c = data[i].get('Relationship__c'),
                Percentage_Beneficiary__c = decimal.valueOf(data[i].get('Percentage_Beneficiary__c'))
            );
            System.debug('Account '+opty.AccountId);
            ocr.ContactId = newContacts[i].Id;
            ocr.OpportunityId = opty.Id;
            ocr.Role = 'ผู้รับผลประโยชน์';
            // ocr.Account__r.Id = opty.AccountId;
            System.debug(ocr.ContactId);
            System.debug(ocr.OpportunityId);
            newOcr.add(ocr);
            
        }
        System.debug(newOcr);
        insert newOcr;*/

    }
}