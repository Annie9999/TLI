@RestResource(urlMapping = '/createLead')
global without sharing class api_CreateLead{

    global virtual class RespondDetail {
        global  integer code {get; set;}
        global  boolean success {get; set;}
        global  string message {get; set;}
    }

    global class PostRespond extends RespondDetail
    {               
        public LeadInformation data {get; set;}    
    }

    global class LeadInformation 
    {
        global String leadId  {get; set;}
    }

    global class UpsertInformation {
        global String firstName  {get; set;}
        global String lastName  {get; set;}
        global String product  {get; set;}
        global BirthDate birthDate  {get; set;}
        global String phone  {get; set;}
        global String email  {get; set;}
        global UpsertInformation(){
            birthDate = new BirthDate();
        }
    }

    global class BirthDate {
        global String day  {get; set;}
        global String month  {get; set;}
        global String year  {get; set;}
    }

    @HttpPost
    global static PostRespond createLead(UpsertInformation upsertInformation) {
        RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		UpsertInformation upsertInfo = new UpsertInformation();
        PostRespond respond = new PostRespond();
        try { 

            List<RecordType> recordType = [SELECT Id, Name FROM RecordType where name =: upsertInformation.product LIMIT 1];

            Lead lead = new Lead();
            lead.FirstName = upsertInformation.firstName;
            lead.LastName = upsertInformation.lastName;
            lead.Phone = upsertInformation.phone;
            lead.Email = upsertInformation.email;
            lead.Birthdate_Date__c = upsertInformation.birthDate.day;
            lead.Birthdate_Month__c = upsertInformation.birthDate.month;
            lead.Birthdate_Year__c = upsertInformation.birthDate.year;
            if (!recordType.isEmpty()) {
                lead.RecordTypeId = recordType.get(0).Id;
            }
            
            insert lead;

            LeadInformation leadInfo = new LeadInformation();
            leadInfo.leadId = lead.Id;

			respond.data = leadInfo;
            respond.code = 200;
            respond.success = true;
            respond.message = 'Success';

        } catch (Exception ex) {
            respond.data = null;
            respond.success =    false;
            respond.code    =    500;
            respond.message = ex.getMessage();
        }
		return respond;
        
    }

}