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
        public String                   InsureName      {get;set;}
        @AuraEnabled
        public String                   taxdeduction    {get;set;}
        @AuraEnabled
        public String                   policyChannel   {get;set;}
        @AuraEnabled
        public Payment_Type__c          payment         {get;set;}
        @AuraEnabled
        public Contact_Role__c          payor           {get;set;}
        @AuraEnabled
        public List<Address>            address         {get;set;}

        public PaymentInfo(){
            payment = new Payment_Type__c();
            payor = new Contact_Role__c();
            address = new List<Address> {new Address('Shipping'), new Address('Billing')};
        }
    }

    @AuraEnabled
    public static PaymentInfo getPaymentInformation(String leadId){

        System.debug('getPaymentInformation : ' + leadId);
        PaymentInfo payInfo = new PaymentInfo();

        List<Lead> leadList = [SELECT Id, FirstName, LastName, Amount_Currency__c, Taxdeduction__c, Policy_Trans_Channel__c, 
                                (SELECT Id, Name, Payment_Bank_Code__c, Payment_Card_Type__c, Payment_Expired_Date__c, 
                                Payment_Card_Number__c, Contact__c, Application_Form__c,Payment_Type__c, Transfer_Bank_Code__c, 
                                Bank_Account_Type__c, IsPayment__c,REF_Number__c, Payment_Date__c, Payment_Status__c, 
                                Register_Status__c, Payment_Detail__c FROM Payment_Types__r),
                                (SELECT Id, Payment_Type__c, Relationship__c, Lead__c,
                                Lead__r.Salutation, Lead__r.FirstName,Lead__r.LastName, Lead__r.Phone, Lead__r.Email, 
                                Lead__r.Street__c, Lead__r.City__c, Lead__r.PostalCode__c, Lead__r.State__c, Lead__r.Country__c,
                                Lead__r.Street, Lead__r.City, Lead__r.PostalCode, Lead__r.State, Lead__r.Country
                                FROM Contact_Roles__r WHERE Role__c ='ผู้ชำระค่าเบี้ยประกัน')
                                FROM Lead WHERE Id =: leadId];

        // List<Opportunity> oppList = [SELECT Id , Amount, Taxdeduction__c, Policy_Trans_Channel__c, AccountId,
        //                                 (SELECT Id, Name, Payment_Bank_Code__c, Payment_Card_Type__c, Payment_Expired_Date__c, 
        //                                 Payment_Card_Number__c, Contact__c, Application_Form__c,Payment_Type__c, Transfer_Bank_Code__c, 
        //                                 Bank_Account_Type__c, IsPayment__c,REF_Number__c, Payment_Date__c, Payment_Status__c, 
        //                                 Register_Status__c, Payment_Detail__c FROM Payment_Types__r),

        //                                 (SELECT Id, Payment_Type__c, Relationship__c, Account__r.id, Account__r.FirstName, 
        //                                 Account__r.LastName, Account__r.Salutation, Account__r.Phone, Account__r.Email__c, 
        //                                 Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingPostalCode, 
        //                                 Account__r.BillingState, Account__r.BillingCountry, Account__r.PersonMailingStreet,
        //                                 Account__r.PersonMailingCity, Account__r.PersonMailingState, Account__r.PersonMailingPostalCode, 
        //                                 Account__r.PersonMailingCountry, Account__r.ShippingStreet , Account__r.ShippingCity,
        //                                 Account__r.ShippingPostalCode, Account__r.ShippingState, Account__r.ShippingCountry 
        //                                 FROM OpportunityContactRoles WHERE role='ผู้ชำระค่าเบี้ยประกัน')  
                                    
        //                                 FROM Opportunity WHERE Id =: opptyId];

                                    
        if(leadList.size() > 0){
            payInfo.InsureName = leadList[0].FirstName + ' ' + leadList[0].LastName;
            payInfo.Amount = leadList[0].Amount_Currency__c;
            payInfo.taxdeduction =  leadList[0].Taxdeduction__c;
            payInfo.policyChannel = leadList[0].Policy_Trans_Channel__c;
            //payInfo.accId = leadList[0].AccountId;
            if(leadList[0].Payment_Types__r.size() > 0 ){
                payInfo.payment = leadList[0].Payment_Types__r[0];
               
            }

            if(leadList[0].Contact_Roles__r.size() > 0){
                payInfo.payor = leadList[0].Contact_Roles__r[0];
                payInfo.address = groupAddress(leadList[0].Contact_Roles__r[0]);
            }

        }
        
        return payInfo;
    }

    public static List<Address> groupAddress(Contact_Role__c payor){
        List<Address> addressList = new List<Address>();
        if(payor.Lead__c != null){
            Address billingAddress = new Address('Billing');
            billingAddress.address          =  payor.Lead__r.Street__c;
            billingAddress.province         =  payor.Lead__r.State__c;
            billingAddress.district         =  payor.Lead__r.City__c;
            billingAddress.subDistrict      =  payor.Lead__r.Country__c;
            billingAddress.postalCode       =  payor.Lead__r.PostalCode__c; 
            addressList.add(billingAddress);

            /*Address mailingAddress = new Address('Mailing');
            mailingAddress.address          =  payor.Account__r.PersonMailingStreet;
            mailingAddress.province         =  payor.Account__r.PersonMailingState;
            mailingAddress.district         =  payor.Account__r.PersonMailingCity;
            mailingAddress.subDistrict      =  payor.Account__r.PersonMailingCountry;
            mailingAddress.postalCode       =  payor.Account__r.PersonMailingPostalCode; 
            addressList.add(mailingAddress);*/

            Address shippingAddress = new Address('Shipping');
            shippingAddress.address          =  payor.Lead__r.Street;
            shippingAddress.province         =  payor.Lead__r.State;
            shippingAddress.district         =  payor.Lead__r.City;
            shippingAddress.subDistrict      =  payor.Lead__r.Country;
            shippingAddress.postalCode       =  payor.Lead__r.PostalCode; 
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
        res.pa_relationShip = getPickListValuesIntoList(Contact_Role__c.Relationship__c.getDescribe());
        res.pa_salutation = getPickListValuesIntoList(Lead.Salutation.getDescribe());

        return res;
    }

    @AuraEnabled
    public static void savePaymentInformation(String paymentInfoString, String leadId, String addressType){
        String opptyId = '';
        System.debug(paymentInfoString);
        System.debug(addressType);
        PaymentInfo paymentInfo = (PaymentInfo)JSON.deserialize(paymentInfoString, PaymentInfo.Class);
        System.debug(paymentInfo);
        /* Update Lead */
        Lead leadInsure = new Lead();
        leadInsure.id = leadId;
       
        if (paymentInfo.taxdeduction != '') {
            leadInsure.Taxdeduction__c = paymentInfo.taxdeduction;
        }

        if (paymentInfo.policyChannel != '') {
            leadInsure.Policy_Trans_Channel__c = paymentInfo.policyChannel;
        }

        leadInsure.Taxdeduction__c = 'ลดหย่อนภาษี';
        leadInsure.Policy_Trans_Channel__c = 'อีเมล';
        leadInsure.Status = 'รอการชำระเงิน';

        if(paymentInfo.Payment.Payment_Type__c == 'Payment Gateway'){
            leadInsure.Payment_Status__c = 'ตัดเงินสำเร็จ';
        }

        update leadInsure;

        /* Paymentinfo */
        Payment_Type__c payment = new Payment_Type__c();
        if(paymentInfo.payment.Id != null){
            payment.Id = paymentInfo.payment.Id;
        }

        payment.Contact__c = paymentInfo.payment.Contact__c; 
        payment.Application_Form__c = paymentInfo.payment.Application_Form__c;
        payment.Payment_Type__c = paymentInfo.payment.Payment_Type__c;
        payment.Payment_Date__c = paymentInfo.payment.Payment_Date__c;
        payment.Lead__c = leadId;
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

        System.debug('Payment Status: '+ payment.Payment_Status__c);


        /* Payor */
        System.debug('paymentInfo.payment.Payment_Type__c' + paymentInfo.payment.Payment_Type__c);
        String leadPayorId = '';
        if(paymentInfo.payor.Relationship__c != 'ตนเอง' && paymentInfo.payment.Payment_Type__c != 'Payment Gateway'){
            System.debug('leadobj : ' + paymentInfo.payor);
            Lead leadobj = new Lead();
            if(paymentInfo.payor.Lead__c != null){
                leadobj.id = paymentInfo.payor.Lead__c;
            }
            leadobj.FirstName           = paymentInfo.payor.Lead__r.FirstName; 
            leadobj.LastName            = paymentInfo.payor.Lead__r.LastName; 
            leadobj.Salutation          = paymentInfo.payor.Lead__r.Salutation; 
            leadobj.Phone               = paymentInfo.payor.Lead__r.Phone; 
            leadobj.Email            = paymentInfo.payor.Lead__r.Email; 
            for(PaymentInformationCtrl.Address each : paymentInfo.address){
                System.debug(addressType);
                System.debug(each);
                if(each.type == 'Billing' && addressType == 'Billing'){
                    leadobj.Street__c       = each.address;  
                    leadobj.State__c        = each.province; 
                    leadobj.City__c         = each.district; 
                    leadobj.Country__c      = each.subDistrict; 
                    leadobj.PostalCode__c   = each.postalCode; 
                    
                }else if (each.type == 'Shipping' && addressType == 'Shipping') {
                    leadobj.Street      = each.address; 
                    leadobj.State       = each.province; 
                    leadobj.City        = each.district; 
                    leadobj.Country     = each.subDistrict; 
                    leadobj.PostalCode  = each.postalCode; 
                }
            }
            Upsert leadobj;
            leadPayorId = leadobj.id;
        }else{
            leadPayorId = leadId;
            paymentInfo.payor.Relationship__c = 'ตนเอง';
        }
        
        /*Account accountCon= [Select Id,PersonContactId 
                                from Account where id = :accountId]; */

        Contact_Role__c contactRole = new Contact_Role__c();
        if(paymentInfo.payor.Id != null){
            contactRole.Id = paymentInfo.payor.Id;
        }
        contactRole.Role__c = 'ผู้ชำระค่าเบี้ยประกัน';
        contactRole.Lead__c = leadPayorId;
        contactRole.Relationship__c = paymentInfo.payor.Relationship__c;
        contactRole.Payment_Type__c = payment.Id;
        //contactRole.ContactId = accountCon.PersonContactId;
        Upsert contactRole;
        /*if(paymentInfo.payor.Id != null){
            contactRole.Id = paymentInfo.payor.Id;
            contactRole.Role = 'ผู้ชำระค่าเบี้ยประกัน';
            contactRole.Account__c = accountId;
            contactRole.Relationship__c = paymentInfo.payor.Relationship__c;
            contactRole.Payment_Type__c = payment.Id;
            contactRole.ContactId = accountCon.PersonContactId;
            update contactRole;
        }else{
            contactRole.Role = 'ผู้ชำระค่าเบี้ยประกัน';
            contactRole.Account__c = accountId;
            contactRole.OpportunityId = opptyId;
            contactRole.Relationship__c = paymentInfo.payor.Relationship__c;
            contactRole.Payment_Type__c = payment.Id;
            contactRole.ContactId = accountCon.PersonContactId;
            insert contactRole;
        }*/

        if (paymentInfo.Payment.Payment_Type__c == 'โอนเงินผ่านบัญชีธนาคาร' || paymentInfo.Payment.Payment_Type__c == 'หักผ่านบัญชีเงินฝาก') {
            Utility.AttachPDF('PaySlipDemo', leadId);
        }

        createCase(paymentInfo.payment.Payment_Type__c, leadId, paymentInfo.insureName);
        
    }

    public static void createCase(String paymentType, String leadId, String insureName){

        if(leadId != ''){
            //List<Opportunity> opptyList = [SELECT id, name, account.id, account.name, OwnerId FROM Opportunity WHERE id =: opptyId];
            System.debug('paymentType' + paymentType);
            if(paymentType == 'Payment Gateway'){
                List<Group> groupList = [SELECT Id, Name, Type, DeveloperName FROM Group WHERE DeveloperName = 'Collection_Queue' AND type = 'Queue'];
                if(groupList.size() > 0){
                    Utility.createCase('ติดตามสถานะการจ่ายเงินของคุณ ' + insureName, 'ส่ง link จ่ายเงินในวันที่ ' + Date.today(), 'Medium', leadId, groupList[0].id, 'DM Process');
                    Utility.sendEmail(leadId, 'SendPayment', false);
                }
            }else {
                // Owner Id is Hard Code naja
                Utility.createCase('ตรวจเช็คสถานะการจ่ายเงิน ' + insureName, 'ประเภทการจ่ายเงิน ' +  paymentType, 'Medium', leadId, '00Gq0000003NkpH', 'DM Process');
                Utility.AttachPDF('PaymentResult', leadId);
            }
        }
        
    }
    
    /*@AuraEnabled
    public static void SendEPolicy(String opptyId){
        System.debug('opptyId ' + opptyId);
        Utility.sendEmail(opptyId, 'SendEPolicy',true);
    }*/

    @AuraEnabled
    public static void sendSMS(String recordId, String paymentType){
        Sendsms sms = new Sendsms();

        // Select Detail 
        Lead ld = [SELECT id, FirstName, Amount_Currency__c FROM Lead WHERE Id=:recordId];
        
        String smsText = '';

        if (paymentType == 'ชำระผ่านเคาน์เตอร์') {
            smsText = 'ชำระเบี้ย คุณ '+ ld.FirstName +' จำนวนทั้งสิ้น '+ ld.Amount_Currency__c +' บาท Ref: TLIS2374 ส่งหลักฐานการชำระเงิน https://bit.ly/2WCamJA';
        }
        else {
            smsText = 'ชำระเบี้ย คุณ '+ ld.FirstName +' จำนวนทั้งสิ้น '+ ld.Amount_Currency__c +' บาท ส่งหลักฐานการชำระเงิน https://bit.ly/2WCamJA';
        }

        System.debug(smsText);

        sms.smsBody = smsText;

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