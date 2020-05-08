public class Sendsms{
     public String phNumber {get;set;}
     public String smsBody {get;set;}
     public String requestId {get;set;}
     public String otpCode {get;set;}
     String accountSid;
     string token;
     String fromPhNumber;
     string toPhNumber;
     errorResponseWrapper erw;

     public sendsms(){
         //phNumber ='+'+Apexpages.currentpage().getparameters().get('phNumber');
         // P'Jiew Account
         // accountSid = 'ACfbfbbb47003dd338aaf4d162ea8db7a2';
         // token = 'fd53f15d2ee777314c8ad3f51454af13';
         // fromPhNumber = '+12052933108';

         // James Account Test
         DM_Constatant__mdt constatant = [SELECT AccountSid__c, FromPhoneNumber__c, Sms_Messenge__c, Token__c, 	ToPhoneNumber__c FROM DM_Constatant__mdt LIMIT 1];

         accountSid = constatant.AccountSid__c;
         token = constatant.Token__c;
         fromPhNumber = constatant.FromPhoneNumber__c;
         toPhNumber = constatant.ToPhoneNumber__c;
         smsBody = constatant.Sms_Messenge__c;
     }

    public void processSms(){
        processSms(phNumber,smsBody);
    }
    
    public void processSms(String phNumber,String smsBody){
         HttpRequest req = new HttpRequest();
         req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/'+accountSid+'/SMS/Messages.json');
         req.setMethod('POST');
         String VERSION  = '3.2.0';
         req.setHeader('X-Twilio-Client', 'salesforce-' + VERSION);
         req.setHeader('User-Agent', 'twilio-salesforce/' + VERSION);
         req.setHeader('Accept', 'application/json');
         req.setHeader('Accept-Charset', 'utf-8');
         req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));
         req.setBody('To='+EncodingUtil.urlEncode(toPhNumber,'UTF-8')+'&From='+EncodingUtil.urlEncode(fromPhNumber,'UTF-8')+'&Body='+smsBody);
         Http http = new Http();
         HTTPResponse res = http.send(req);
         System.debug(res.getBody());
         if(res.getStatusCode()==201)
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'SMS Sent Successfully'));
         else{
             erw =(errorResponseWrapper)json.deserialize(res.getBody(),errorResponseWrapper.class);
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,erw.message));
         }
     }

    public String sendSms(){
        HttpRequest req = new HttpRequest();

        String smsText = '';

        if (smsBody != '') {
            smsText = smsBody;
        }

        req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/'+accountSid+'/SMS/Messages.json');
        req.setMethod('POST');
        String VERSION  = '3.2.0';
        req.setHeader('X-Twilio-Client', 'salesforce-' + VERSION);
        req.setHeader('User-Agent', 'twilio-salesforce/' + VERSION);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Accept-Charset', 'utf-8');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));
        req.setBody('To='+EncodingUtil.urlEncode(toPhNumber,'UTF-8')+'&From='+EncodingUtil.urlEncode(fromPhNumber,'UTF-8')+'&Body='+smsText);
        Http http = new Http();
        HTTPResponse res = http.send(req);

        System.debug(res.getBody());

        if(res.getStatusCode()==201)
            return 'SMS send successfully';
        else{
            return 'SMS send fail';
        }
    }

    public string sendSmsOTP(){
        string result = sendSmsOTP(requestId, phNumber);
        return result;
    }

    public string vertifySmsOTP(){
        string result = vertifySmsOTP(requestId, otpCode);
        return result;
    }

    private String sendSmsOTP(String requestId, String phNumber){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/'+accountSid+'/SMS/Messages.json');
        req.setMethod('POST');
        String VERSION  = '3.2.0';
        req.setHeader('X-Twilio-Client', 'salesforce-' + VERSION);
        req.setHeader('User-Agent', 'twilio-salesforce/' + VERSION);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Accept-Charset', 'utf-8');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));

        // Set SMS body content
        String content = 'รหัส OTP ของคุณคือ';

        OTPManager otpm = new OTPManager();
        OTP__c otp = otpm.requestOTP(requestId);

        System.debug(otp.OTP_Code__c);
        
        req.setBody('To='+EncodingUtil.urlEncode(phNumber,'UTF-8')+'&From='+EncodingUtil.urlEncode(fromPhNumber,'UTF-8')+'&Body=' + content + ': ' + otp.OTP_Code__c);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());

        if(res.getStatusCode()==201)
            // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'SMS Sent Successfully'));
            return 'SMS Sent Successfully';
        else{
            // erw =(errorResponseWrapper)json.deserialize(res.getBody(),errorResponseWrapper.class);
            // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,erw.message));
            return erw.message;
        }
        
    }

    private String vertifySmsOTP(String requestId, String otpCode){
        OTPManager otpm = new OTPManager();
        Boolean result = otpm.verifyOTP(requestId, otpCode);

        if (result) {
            return 'Vertify Success.';
        }

        return 'Cannot use OTP Code.';
    }

     public class errorResponseWrapper{
         String code;
         String message;
         String moreInfo;
         String status;    
     }
}