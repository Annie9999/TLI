public class ProductFormApexController {

    @AuraEnabled
    public static void saveProduct(String opptyId,String amount,String product,string subProduct,string birthdate,string gender,string payment) {
        System.debug('----- '+opptyId+' '+amount+' '+product+' '+subProduct+' '+birthdate+' '+gender+' '+payment);
        List<Opportunity> opptyList = [select Id,productgroup__c,Sub_productgroup__c,Payment_Mode__c,Amount,Name,AccountId, Account.PersonEmail from Opportunity where id = :opptyId];
        List<Account> accList = [SELECT Id, Name, LastName, FirstName, Salutation, Type, Sex__pc,PersonBirthdate from Account where id = :opptyList[0].AccountId];
        try{
            Account acc = new Account();
            acc.Id = accList[0].Id;
            acc.Sex__pc =gender;
            acc.PersonBirthdate =date.valueOf(birthdate);
            update acc;

            Opportunity oppty = new Opportunity();
            oppty.Id = opptyList[0].Id;
            oppty.Amount =Decimal.valueOf(amount.replaceAll(',',''));
            oppty.Payment_Mode__c =payment;
            oppty.productgroup__c = product;
            oppty.Sub_productgroup__c = subProduct;
            oppty.gender__c = gender;
            update oppty;
            List<OpportunityLineItem> opptyItemList = [SELECT Id, OpportunityId, PricebookEntryId, Product2Id, ProductCode, Name, TotalPrice, Quantity FROM OpportunityLineItem where OpportunityId = :opptyId];
            // List<Product2> prodLists= [SELECT Id, Name, ProductCode, Description, Family FROM Product2 where Name =:subProduct];
            List<Pricebook2> priceBooks = [SELECT Id, Name, IsActive, IsArchived FROM Pricebook2 where IsActive = true];
            List<PricebookEntry> priceBookEntrys = [SELECT Id, Name, Pricebook2Id, Product2Id FROM PricebookEntry where Pricebook2Id = :priceBooks[0].id and Name =: subProduct];
            if(opptyItemList.size()>0){
                delete opptyItemList;
            }
            if(priceBookEntrys.size()>0){
                OpportunityLineItem OppLine = new OpportunityLineItem();
                OppLine.PricebookEntryId = priceBookEntrys[0].Id;
                OppLine.OpportunityId = opptyId;
                OppLine.TotalPrice = Decimal.valueOf(amount.replaceAll(',',''));
                OppLine.Quantity = 1;
                insert OppLine;
            }
        
        }
        catch(exception e){
            system.debug('------------ '+e.getMessage());
            system.debug('------------ '+e.getStackTraceString());
        }
    }

    // save ACC Product
    @AuraEnabled
    public static void saveACCProduct(String opptyId,String amount,String product,string subProduct,string birthdate,string gender,string payment) {
        
        System.debug('----- '+opptyId+' '+amount+' '+product+' '+subProduct+' '+birthdate+' '+gender+' '+payment);
        List<Opportunity> opptyList = [ SELECT Id, Name, AccountId, Date_Of_Birth__c, gender__c, Amount, sub_insurance__c, totalamount__c, howtopay__c, Payment_Mode__c, amount__c, productgroup__c
                                        FROM Opportunity
                                        WHERE id = :opptyId];
        
        try{
            Opportunity opp = opptyList[0];
            opp.Date_Of_Birth__c = date.valueOf(birthdate);
            opp.totalamount__c = amount.replaceAll(',','');
            // opp.totalamount__c = '1000.98';
            opp.productgroup__c = product;
            opp.Sub_productgroup__c = subProduct;
            opp.gender__c = gender;
            opp.Payment_Mode__c = payment;
            update opp;

            List<OpportunityLineItem> opptyItemList = [SELECT Id, OpportunityId, PricebookEntryId, Product2Id, ProductCode, Name, TotalPrice, Quantity FROM OpportunityLineItem where OpportunityId =:opptyId];
            System.debug('opptyItemList: ' + opptyItemList);
            if(opptyItemList.size()>0){
                delete opptyItemList;
            }

            Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
            List<Product2> prodList= [SELECT Id, Name, ProductCode, Description, Family FROM Product2 WHERE Name =:subProduct];
            System.debug('standardPb: ' + standardPb);
            System.debug('prodList: ' + prodList);
            if(prodList.size()>0){
                
                List<PriceBookEntry> priceBookList = [SELECT Id, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry where Product2.Name =:subProduct];
                System.debug('priceBookList: ' + priceBookList);
                OpportunityLineItem OppLine = new OpportunityLineItem();

                if(priceBookList.isEmpty()){
                    PricebookEntry pbe1 = new PricebookEntry ();
                    pbe1.Product2ID=prodList[0].id;
                    pbe1.Pricebook2ID=standardPb.id;
                    pbe1.UnitPrice=100;
                    pbe1.isActive=true;
                    insert pbe1;

                    OppLine.PricebookEntryId = pbe1.Id ;
                }else{
                    OppLine.PricebookEntryId = priceBookList[0].Id ;
                }
                OppLine.OpportunityId = opptyId;
                OppLine.TotalPrice = Decimal.valueOf(amount.replaceAll(',',''));
                OppLine.Quantity = 1;
                insert OppLine;
                System.debug('OppLine: ' + OppLine);
            }
        }
        catch(exception e){
            system.debug('------------ '+e.getMessage());
            system.debug('------------ '+e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void sendQuotation(String opptyId) {
        Utility.sendEmail(opptyId,'SendQuotation',false);
    }

    @AuraEnabled
    public static responseValue getDetail(string oppId) {
        ProductFormApexController.responseValue res= new ProductFormApexController.responseValue();
        System.debug('oppId' +oppId);
        Opportunity opp = new Opportunity();
        opp = [SELECT id,AccountId,productgroup__c,Sub_productgroup__c,name,Payment_Mode__c,Amount, Date_Of_Birth__c, gender__c FROM Opportunity where id =: oppId];
        Account acc = new Account();
        acc = [SELECT id, name,Sex__pc,PersonBirthdate,FirstName,LastName FROM Account where id =: opp.AccountId];
        OpportunityLineItem opptyLine = new OpportunityLineItem();
        List<OpportunityLineItem> opptyLines = [SELECT Id, OpportunityId, PricebookEntryId, Product2Id,Product2.Name, ProductCode, Name, TotalPrice, Quantity FROM OpportunityLineItem where OpportunityId =:oppId];
        res.opptyObj = opp;
        res.accObj = acc;

        res.mapDependent = getDependentMap();

        System.debug('res.opptyObj '+res.opptyObj);
        System.debug('res.accObj '+res.accObj);
        System.debug('res.mapDependent '+res.mapDependent);
        return res;
    }

    // @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(){
        string contrfieldApiName='productgroup__c';
        string depfieldApiName='Sub_productgroup__c';
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
    
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        // sObject leadOb = new Lead();

        Schema.sObjectType objType = Lead.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);

            // System.debug('controllingValues '+controllingValues);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
            // System.debug('objResults '+objResults);
        }
        System.debug('Testtt '+objResults);
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }

    public class responseValue{
        @AuraEnabled public Opportunity opptyObj {get;set;}
        @AuraEnabled public Account accObj {get;set;}
        @AuraEnabled public Map<String, List<String>> mapDependent {get;set;}       
    }

}