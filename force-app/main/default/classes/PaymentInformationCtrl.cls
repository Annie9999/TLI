public without sharing class PaymentInformationCtrl {
    
    public class OptionWrapper{
        /* Credit Card*/
        @AuraEnabled
        public List<String> cc_bankCode {get;set;}
        @AuraEnabled
        public List<String> cc_cardType {get;set;}
        /* Payer */
        @AuraEnabled
        public List<String> pa_relationShip {get;set;}
        @AuraEnabled
        public List<String> pa_salutation {get;set;}
        /* */
        @AuraEnabled
        public List<String> db_paymentStatus {get;set;}
        @AuraEnabled
        public List<String> db_registerStatus {get;set;}
        @AuraEnabled
        public List<String> db_paymentDetail {get;set;}
    }

    public class Address{
        @AuraEnabled
        public String   type          {get;set;}
        @AuraEnabled
        public String   address       {get;set;}
        @AuraEnabled
        public String   province      {get;set;}
        @AuraEnabled
        public String   subDistrict   {get;set;}
        @AuraEnabled
        public String   district      {get;set;}
        @AuraEnabled
        public String   postalCode    {get;set;}

        public Address(){
        }
        
        public Address(String aType){
            type = aType;
        }
    }

    public class PaymentInfo{
        @AuraEnabled
        public Decimal                  Amount          {get;set;}
        @AuraEnabled
        public String                   taxdeduction    {get;set;}
        @AuraEnabled
        public String                   policyChannel   {get;set;}
        @AuraEnabled
        public String                   accId           {get;set;}
        @AuraEnabled
        public Payment_Type__c          payment         {get;set;}
        @AuraEnabled
        public OpportunityContactRole   payor           {get;set;}
        @AuraEnabled
        public List<Address>            address         {get;set;}

        public PaymentInfo(){
            payment = new Payment_Type__c();
            payor = new OpportunityContactRole();
            address = new List<Address> {new Address('Shipping'), new Address('Mailing'), new Address('Billing')};
        }
    }

    @AuraEnabled
    public static PaymentInfo getPaymentInformation(String opptyId){

        System.debug('getPaymentInformation : ' + opptyId);
        PaymentInfo payInfo = new PaymentInfo();

        List<Opportunity> oppList = [SELECT Id , Amount, Taxdeduction__c, Policy_Trans_Channel__c, AccountId,
                                        (SELECT Id, Name, Payment_Bank_Code__c, Payment_Card_Type__c, Payment_Expired_Date__c, 
                                        Payment_Card_Number__c, Contact__c, Application_Form__c,Payment_Type__c, Transfer_Bank_Code__c, 
                                        Bank_Account_Type__c, IsPayment__c,REF_Number__c, Payment_Date__c, Payment_Status__c, 
                                        Register_Status__c, Payment_Detail__c FROM Payment_Types__r),

                                        (SELECT Id, Payment_Type__c, Relationship__c, Account__r.id, Account__r.FirstName, 
                                        Account__r.LastName, Account__r.Salutation, Account__r.Phone, Account__r.Email__c, 
                                        Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingPostalCode, 
                                        Account__r.BillingState, Account__r.BillingCountry, Account__r.PersonMailingStreet,
                                        Account__r.PersonMailingCity, Account__r.PersonMailingState, Account__r.PersonMailingPostalCode, 
                                        Account__r.PersonMailingCountry, Account__r.ShippingStreet , Account__r.ShippingCity,
                                        Account__r.ShippingPostalCode, Account__r.ShippingState, Account__r.ShippingCountry 
                                        FROM OpportunityContactRoles WHERE role='ผู้ชำระค่าเบี้ยประกัน')  
                                    
                                        FROM Opportunity WHERE Id =: opptyId];

                                    
        if(oppList.size() > 0){
            System.debug('oppList[0].Amount : ' + oppList[0].Amount);
            system.debug('Payment: ' +oppList[0].Payment_Types__r[0]);

            payInfo.Amount = oppList[0].Amount;
            payInfo.taxdeduction =  oppList[0].Taxdeduction__c;
            payInfo.policyChannel = oppList[0].Policy_Trans_Channel__c;
            payInfo.accId = oppList[0].AccountId;
            if(oppList[0].Payment_Types__r.size() > 0 ){
                payInfo.payment = oppList[0].Payment_Types__r[0];
               
            }

            if(oppList[0].OpportunityContactRoles.size() > 0){
                payInfo.payor = oppList[0].OpportunityContactRoles[0];
                payInfo.address = groupAddress(oppList[0].OpportunityContactRoles[0]);
            }

        }
        
        return payInfo;
    }

    public static List<Address> groupAddress(OpportunityContactRole payor){
        List<Address> addressList = new List<Address>();
        if(payor.Account__c != null){
            Address billingAddress = new Address('Billing');
            billingAddress.address          =  payor.Account__r.BillingStreet;
            billingAddress.province         =  payor.Account__r.BillingState;
            billingAddress.district         =  payor.Account__r.BillingCity;
            billingAddress.subDistrict      =  payor.Account__r.BillingCountry;
            billingAddress.postalCode       =  payor.Account__r.BillingPostalCode; 
            addressList.add(billingAddress);

            Address mailingAddress = new Address('Mailing');
            mailingAddress.address          =  payor.Account__r.PersonMailingStreet;
            mailingAddress.province         =  payor.Account__r.PersonMailingState;
            mailingAddress.district         =  payor.Account__r.PersonMailingCity;
            mailingAddress.subDistrict      =  payor.Account__r.PersonMailingCountry;
            mailingAddress.postalCode       =  payor.Account__r.PersonMailingPostalCode; 
            addressList.add(mailingAddress);

            Address shippingAddress = new Address('Shipping');
            shippingAddress.address          =  payor.Account__r.ShippingStreet;
            shippingAddress.province         =  payor.Account__r.ShippingState;
            shippingAddress.district         =  payor.Account__r.ShippingCity;
            shippingAddress.subDistrict      =  payor.Account__r.ShippingCountry;
            shippingAddress.postalCode       =  payor.Account__r.ShippingPostalCode; 
            addressList.add(shippingAddress);
        }
        
        return addressList;
    }

    @AuraEnabled
    public static OptionWrapper getOption(){
        OptionWrapper res = new OptionWrapper();
       
        res.cc_bankCode = getPickListValuesIntoList(Payment_Type__c.Payment_Bank_Code__c.getDescribe());
        res.cc_cardType = getPickListValuesIntoList(Payment_Type__c.Payment_Card_Type__c.getDescribe());
        res.db_paymentStatus = getPickListValuesIntoList(Payment_Type__c.Payment_Status__c.getDescribe());
        res.db_registerStatus = getPickListValuesIntoList(Payment_Type__c.Register_Status__c.getDescribe());
        res.db_paymentDetail = getPickListValuesIntoList(Payment_Type__c.Payment_Detail__c.getDescribe());
        res.pa_relationShip = getPickListValuesIntoList(OpportunityContactRole.Relationship__c.getDescribe());
        res.pa_salutation = getPickListValuesIntoList(Account.Salutation.getDescribe());

        return res;
    }

    @AuraEnabled
    public static void savePaymentInformation(String paymentInfoString, String opptyId, String addressType){
        System.debug(paymentInfoString);
        System.debug(addressType);
        PaymentInfo paymentInfo = (PaymentInfo)JSON.deserialize(paymentInfoString, PaymentInfo.Class);
        System.debug(paymentInfo.address);
        /* Update Opportunity */
        Opportunity oppty = new Opportunity();
        oppty.id = opptyId;
        oppty.Taxdeduction__c = paymentInfo.taxdeduction;
        oppty.Policy_Trans_Channel__c = paymentInfo.policyChannel;
        update oppty;

        /* Paymentinfo */
        Payment_Type__c payment = new Payment_Type__c();
        if(paymentInfo.payment.Id != null){
            payment.Id = paymentInfo.payment.Id;
        }

        payment.Contact__c = paymentInfo.payment.Contact__c; 
        payment.Application_Form__c = paymentInfo.payment.Application_Form__c;
        payment.Payment_Type__c = paymentInfo.payment.Payment_Type__c;
        payment.Payment_Date__c = paymentInfo.payment.Payment_Date__c;
        payment.Opportunity__c = opptyId;
        /* Credit Card */
        payment.Payment_Bank_Code__c = paymentInfo.payment.Payment_Bank_Code__c;
        payment.Payment_Card_Type__c = paymentInfo.payment.Payment_Card_Type__c;
        payment.Payment_Expired_Date__c = paymentInfo.payment.Payment_Expired_Date__c;
        payment.Payment_Card_Number__c = paymentInfo.payment.Payment_Card_Number__c;
        /* Transfer */
        payment.Transfer_Bank_Code__c = paymentInfo.payment.Transfer_Bank_Code__c;
        payment.Bank_Account_Type__c = paymentInfo.payment.Bank_Account_Type__c;
        /* Counter Service */
        payment.REF_Number__c = paymentInfo.payment.REF_Number__c;
        /* Debited Account */
        payment.Payment_Status__c = paymentInfo.payment.Payment_Status__c;
        payment.Register_Status__c = paymentInfo.payment.Register_Status__c;
        payment.Payment_Detail__c = paymentInfo.payment.Payment_Detail__c;
        upsert payment;

        /* Payor */
        System.debug('paymentInfo.payment.Payment_Type__c' + paymentInfo.payment.Payment_Type__c);
        String accountId = '';
        if(paymentInfo.payor.Relationship__c != 'ตนเอง' && paymentInfo.payment.Payment_Type__c != 'Payment Gateway'){
            Account acc = new Account();
            System.debug(paymentInfo.payor.Account__c);
            if(paymentInfo.payor.Account__c != null){
                acc.id = paymentInfo.payor.Account__c;
            }
            acc.FirstName           = paymentInfo.payor.Account__r.FirstName; 
            acc.LastName            = paymentInfo.payor.Account__r.LastName; 
            acc.Salutation          = paymentInfo.payor.Account__r.Salutation; 
            acc.Phone               = paymentInfo.payor.Account__r.Phone; 
            acc.Email__c            = paymentInfo.payor.Account__r.Email__c; 
            for(PaymentInformationCtrl.Address each : paymentInfo.address){
                system.debug(addressType);
                System.debug(each);
                if(each.type == 'Billing' && addressType == 'Billing'){
                    acc.BillingStreet       = each.address;  
                    acc.BillingState        =  each.province; 
                    acc.BillingCity         = each.district; 
                    acc.BillingCountry      = each.subDistrict; 
                    acc.BillingPostalCode   = each.postalCode; 
                    
                }else if (each.type == 'Mailing' && addressType == 'Mailing') {
                    acc.PersonMailingStreet = each.address; 
                    acc.PersonMailingState  = each.province; 
                    acc.PersonMailingCity   = each.district; 
                    acc.PersonMailingCountry    = each.subDistrict;
                    acc.PersonMailingPostalCode = each.postalCode; 
                }else if (each.type == 'Shipping' && addressType == 'Shipping') {
                    acc.ShippingStreet      = each.address; 
                    acc.ShippingState        = each.province; 
                    acc.ShippingCity  = each.district; 
                    acc.ShippingCountry       = each.subDistrict; 
                    acc.ShippingPostalCode     = each.postalCode; 
                }
            }
            
            Upsert acc;
            accountId = acc.id;
        }else{
            accountId = paymentInfo.accId;
            paymentInfo.payor.Relationship__c = 'ตนเอง';
        }
        
        Account accountCon= [Select Id,PersonContactId 
                                from Account where id = :accountId]; 

        OpportunityContactRole optyContactRole = new OpportunityContactRole();
        if(paymentInfo.payor.Id != null){
            optyContactRole.Id = paymentInfo.payor.Id;
            optyContactRole.Role = 'ผู้ชำระค่าเบี้ยประกัน';
            optyContactRole.Account__c = accountId;
            optyContactRole.Relationship__c = paymentInfo.payor.Relationship__c;
            optyContactRole.Payment_Type__c = payment.Id;
            optyContactRole.ContactId = accountCon.PersonContactId;
            update optyContactRole;
        }else{
            optyContactRole.Role = 'ผู้ชำระค่าเบี้ยประกัน';
            optyContactRole.Account__c = accountId;
            optyContactRole.OpportunityId = opptyId;
            optyContactRole.Relationship__c = paymentInfo.payor.Relationship__c;
            optyContactRole.Payment_Type__c = payment.Id;
            optyContactRole.ContactId = accountCon.PersonContactId;
            insert optyContactRole;
        }

        createCase(paymentInfo.payment.Payment_Type__c, opptyId);
        
    }

    public static void createCase(String paymentType, String opptyId){

        if(opptyId != ''){
            List<Opportunity> opptyList = [SELECT id, name, account.id, account.name, OwnerId FROM Opportunity WHERE id =: opptyId];
            System.debug('paymentType' + paymentType);
            if(paymentType == 'Payment Gateway'){
                List<Group> groupList = [SELECT Id, Name, Type, DeveloperName FROM Group WHERE DeveloperName = 'Collection_Queue' AND type = 'Queue'];
                if(groupList.size() > 0){
                    Utility.createCase('ติดตามสถานะการจ่ายเงินของคุณ ' + opptyList[0].account.name, 'ส่ง link จ่ายเงินในวันที่ ' + Date.today(), 'Medium', opptyList[0].account.id, opptyId, groupList[0].id, 'DM Process');
                    Utility.sendEmail(opptyId, 'SendPayment',false);
                }
            }else {
                Utility.createCase('ตรวจเช็คสถานะการจ่ายเงิน ' + opptyList[0].name, 'ประเภทการจ่ายเงิน ' +  paymentType, 'Medium', opptyList[0].account.id, opptyId, opptyList[0].OwnerId, 'DM Process');
            }
        }
        
    }
    @AuraEnabled
    public static void SendEPolicy(String opptyId){
        System.debug('opptyId ' + opptyId);
        Utility.sendEmail(opptyId, 'SendEPolicy',true);
    }

    @AuraEnabled
    public static void sendSMS(String phoneNumber, String message){
        System.debug('Send sms ' + phoneNumber);
        System.debug('Send sms ' + message);
        Sendsms sms = new Sendsms();
        sms.phNumber = phoneNumber;
        sms.smsBody = message;
        String result = sms.Sendsms();
        System.debug('Send sms ' + result);
    }

    public static List<String> getPickListValuesIntoList(Schema.DescribeFieldResult fieldResult){
        List<String> pickListValuesList= new List<String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
}