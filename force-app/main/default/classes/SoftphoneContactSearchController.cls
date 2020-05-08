/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

global class SoftphoneContactSearchController {
    webService static String getContacts(String name) {
		List<Contact> contactList = new List<Contact>();
        List<Account> accList = new List<Account>();
        List<Lead> leadList = new List<Lead>();
        
        for (Contact contact: [SELECT Id, Phone, Name, Title, Account.Name FROM Contact WHERE (id = :name OR Name LIKE :('%' + name + '%') OR firstname LIKE :('%' + name + '%') OR lastname LIKE :('%' + name + '%') OR phone LIKE :('%' + name + '%')) LIMIT 10]){
            contactList.add(contact);
        }

        if(contactList.isEmpty()){
            
            for (Account acc: [SELECT Id, Phone, Name FROM Account WHERE (id = :name OR Name LIKE :('%' + name + '%') OR phone LIKE :('%' + name + '%')) LIMIT 10]){
                accList.add(acc);
            }
        }else{
            //get account business
            Set<Id> accSetId = new Set<Id>();
            for(Contact c : contactList){
                accSetId.add(c.AccountId);
            }

            for (Account acc: [SELECT Id, Phone, Name FROM Account WHERE (id in: accSetId OR Name LIKE :('%' + name + '%') OR phone LIKE :('%' + name + '%')) and RecordType.name = 'Business Account']){
                accList.add(acc);
            }
        }

        if(!accList.isEmpty()){
            return JSON.serialize(accList);
        }else if(!contactList.isEmpty()){
            return JSON.serialize(contactList);
        }else{
            for (Lead contact: [SELECT Id, Phone FROM Lead WHERE (id = :name OR Name LIKE :('%' + name + '%') OR firstname LIKE :('%' + name + '%') OR lastname LIKE :('%' + name + '%') OR phone LIKE :('%' + name + '%')) LIMIT 10]){
                leadList.add(contact);
            }
            return JSON.serialize(leadList);
        }
        
    }

    @AuraEnabled
    public static string getWhoId(String recordId){
        String prefixes = recordId.substring(0, 3);

        List<Case> caseList = [SELECT Id, AccountId, ContactId FROM Case WHERE (Id = :recordId 
                                OR AccountId = :recordId OR ContactId = :recordId) ORDER BY CreatedDate DESC LIMIT 1];

        if(caseList.isEmpty() && prefixes != '00Q') { // from Contact
            List<Contact> contactList = [SELECT Id, AccountId FROM Contact WHERE (Id = :recordId OR AccountId = :recordId)];
            return JSON.serialize(contactList);

        } else if (prefixes == '001') { // from Account
            List<Account> accList = [SELECT Id FROM Account WHERE (Id = :recordId)];
            return JSON.serialize(accList);
           /* List<Contact> contactList = [SELECT Id, AccountId FROM Contact WHERE (AccountId = :recordId)];
            return JSON.serialize(contactList);*/

        }else if (prefixes == '00Q') { // from Lead
            List<Lead> leadList = [SELECT Id, Service_Request__c FROM Lead WHERE Id = :recordId];
            return JSON.serialize(leadList); 

        } else {
            return JSON.serialize(caseList);
        }                              
    }
    
}