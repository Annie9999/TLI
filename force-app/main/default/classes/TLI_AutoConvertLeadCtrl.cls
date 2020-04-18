public without sharing class TLI_AutoConvertLeadCtrl {
    public class ResponseWrapper{
        @AuraEnabled
        public ResponseData data{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public String code{get;set;}
        ResponseWrapper(){
            data = new ResponseData();
        }
    }
    public class ResponseData{
        @AuraEnabled
        public string accountId;
        @AuraEnabled
        public string opportunityId;
    }
    @AuraEnabled (cacheable=false)
    public static ResponseWrapper convertLead(Id leadId, Id OwnerId) {


        ResponseWrapper reswrap = new ResponseWrapper();
        // try{
            System.debug(leadId);
            System.debug('UserId= '+OwnerId);
            
            Lead leadObj = [SELECT id,Phone,Email,isConverted,TLI_Division_Create__c,gender__c,
                                    productgroup__c,Sub_productgroup__c,amount__c,Taxdeduction__c,
                                    sub_insurance__c,totalamount__c,howtopay__c,Date_Of_Birth__c ,
                                    OwnerId ,Owner.Name
                            FROM Lead 
                            WHERE id =: leadId];
            List<Account> accExisting = [SELECT id,Name 
                                        FROM Account 
                                        WHERE PersonEmail =:leadObj.Email AND 
                                                Phone =:leadObj.Phone AND  
                                                PersonEmail !=null AND 
                                                Phone !=null AND 
                                                    (RecordTypeId =:Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account Existing').getRecordTypeId() 
                                                    OR RecordTypeId =:Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account Prospect').getRecordTypeId())];
            System.debug('LeadId= '+leadObj.OwnerId );
            String OwnerStr = leadObj.OwnerId;
            
            if(!leadObj.isConverted){

        
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(leadId);
                if(OwnerStr.startsWith('00G')){
                    lc.setOwnerId(OwnerId);
                }
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                if(accExisting.size() > 0){
                    lc.setAccountId(accExisting.get(0).Id);
                }
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                reswrap.data.accountId = lcr.getAccountId();
                reswrap.data.opportunityId = lcr.getOpportunityId();

                Opportunity opptyObj = new Opportunity();
                opptyObj.id = lcr.getOpportunityId();
                opptyObj.productgroup__c = leadObj.productgroup__c; 
                opptyObj.amount__c = leadObj.amount__c; 
                opptyObj.Taxdeduction__c = leadObj.Taxdeduction__c; 
                opptyObj.sub_insurance__c = leadObj.sub_insurance__c; 
                opptyObj.totalamount__c = leadObj.totalamount__c; 
                opptyObj.howtopay__c = leadObj.howtopay__c; 
                opptyObj.Date_Of_Birth__c = leadObj.Date_Of_Birth__c; 
                opptyObj.gender__c = leadObj.gender__c; 
                
                System.debug('RecordType= '+opptyObj.RecordTypeId);
                if(leadObj.TLI_Division_Create__c == null){
                    leadObj.TLI_Division_Create__c = '';
                }
                if(leadObj.TLI_Division_Create__c.Contains('DM')){
                    opptyObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DM Insured').getRecordTypeId();
                }else {
                    opptyObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Acc Insured').getRecordTypeId();
                }
                update opptyObj;
                system.debug('opptyObj : '+ opptyObj);
                system.debug('LeadObj : '+ leadObj);
                system.debug('opptyObj owner: '+ opptyObj.Owner.Name);
                system.debug('LeadObj owner: '+ opptyObj.Owner.Name);
                System.debug('Record Type After= '+ opptyObj.RecordTypeId);
                List<PricebookEntry> priceEnList = [SELECT Id, Product2Id, Product2.Id, Product2.Name 
                                        FROM PriceBookEntry 
                                        WHERE Product2.Name=:leadObj.Sub_productgroup__c AND PriceBook2.isStandard=true LIMIT 1];
                // List<Product2> productObj =  [SELECT Id, Name, ProductCode FROM Product2 WHERE Name =: leadObj.Sub_productgroup__c Limit 1];
                if(priceEnList.size() > 0){
                    OpportunityLineItem oppProducts = new OpportunityLineItem(
                                PricebookEntryId  =  priceEnList.get(0).Id,
                                OpportunityId = opptyObj.id,
                                Quantity = 1, 
                                Discount = 0.0,
                                TotalPrice = 100
                    );
                    insert oppProducts;
                }
                

            }
        // }catch(Exception e){
        //     System.debug(e.getMessage());
        //     throw new AuraHandledException(e.getMessage());
        // }
        
        // reswrap.data.accountId = 'test ja';
        // reswrap.data.opportunityId = 'test ja';
        // reswrap.message = 'success';
        return reswrap;
    }
}