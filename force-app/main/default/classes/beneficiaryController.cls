public without sharing class beneficiaryController {

    @AuraEnabled
    public static void createBeneficiary(String benefList, String oppId){
        System.debug('Hello');
        System.debug(benefList);
        System.debug(oppId);
        System.debug([SELECT Name FROM Opportunity WHERE Id = :oppId]);
        Opportunity opty = [SELECT Id, AccountId FROM Opportunity WHERE Id = :oppId];
        List<Map<String, String>> data = (List<Map<String, String>>)JSON.deserializeStrict(benefList, List<Map<String, String>>.class);

        List<Contact> newContacts = new List<Contact>();
        List<OpportunityContactRole> newOcr = new List<OpportunityContactRole>();
        //Put contacts into list
        for(Map<String, String> m : data){
            //System.debug(date.parse(m.get('Birthdate')));

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
            );*/
            newContacts.add(c);
        }
        
        System.debug(newContacts);
        insert newContacts;
        //Put OpportunityContactRole into list
        //data[i].get('Relationship__c')
        for(Integer i = 0;i < newContacts.size();i++){
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
        insert newOcr;

    }
}