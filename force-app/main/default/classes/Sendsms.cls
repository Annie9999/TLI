public class Sendsms{
     public String phNumber {get;set;}
     public String smsBody {get;set;}
     public String requestId {get;set;}
     public String otpCode {get;set;}
     String accountSid;
     string token;
     String fromPhNumber;
     errorResponseWrapper erw;

     public sendsms(){
         //phNumber ='+'+Apexpages.currentpage().getparameters().get('phNumber');
         // P'Jiew Account
         // accountSid = 'ACfbfbbb47003dd338aaf4d162ea8db7a2';
         // token = 'fd53f15d2ee777314c8ad3f51454af13';
         // fromPhNumber = '+12052933108';

         // James Account Test
         accountSid = 'ACfe78b099650e5d3cb1502d3929d17ffd';
         token = '544152e5d9d3c0451a05e4e71f55ccbd';
         fromPhNumber = '+17178640951';
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
         req.setBody('To='+EncodingUtil.urlEncode(phNumber,'UTF-8')+'&From='+EncodingUtil.urlEncode(fromPhNumber,'UTF-8')+'&Body='+smsBody);
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
        String result = sendSms(phNumber, smsBody);
        return result;
    }

    private String sendSms(String phNumber, String smsBody){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/'+accountSid+'/SMS/Messages.json');
        req.setMethod('POST');
        String VERSION  = '3.2.0';
        req.setHeader('X-Twilio-Client', 'salesforce-' + VERSION);
        req.setHeader('User-Agent', 'twilio-salesforce/' + VERSION);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Accept-Charset', 'utf-8');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));
        req.setBody('To='+EncodingUtil.urlEncode(phNumber,'UTF-8')+'&From='+EncodingUtil.urlEncode(fromPhNumber,'UTF-8')+'&Body='+smsBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);

        System.debug(res.getBody());

        if(res.getStatusCode()==201)
            // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'SMS Sent Successfully'));
            return 'SMS send successfully';
        else{
            // erw =(errorResponseWrapper)json.deserialize(res.getBody(),errorResponseWrapper.class);
            // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,erw.message));
            return erw.message;
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