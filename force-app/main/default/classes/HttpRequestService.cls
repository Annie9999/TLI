public class HttpRequestService {
    private Map<String, String> headers;
    private Map<String, Object> parameters;
    private List<String> DestinationList;
    private boolean SendToSAP;
    @testVisible private HttpRequest request;

    // Start Utilities Methods Section

    //Additional repeat fields
    public static List<String> getRepeatfieldSet(String sObjectName){
        List<String> repeatfieldList = new List<String>();
        if(sObjectName=='Account'){
            repeatfieldList.addAll(getSobjectFieldSet(sObjectName,'Customer_Email_info_fieldset'));
            repeatfieldList.addAll(getSobjectFieldSet(sObjectName,'Customer_Phone_Info_Fieldset'));
        }

        return repeatfieldList;

    }

    //Get Field Set
    public static List<String> getSobjectFieldSet(String sObjectName, String fieldSetName) {
        String result = '';
        List<String> fieldnameList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if(FsMap.containsKey(fieldSetName))
                for(Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    if(result != ''){
                        result += ',';
                    }

                    fieldnameList.add(f.getFieldPath());
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel() + '",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"name":"' + f.getFieldPath() + '"';
                    jsonPart += '}';
                    result += jsonPart;
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        return fieldnameList;
    }

    //Get Relationship SOQL Statements as string
    public static String getRelationshipFieldSOQL(Map<string,String> relationshipfieldMap){
         String soqlstr='';
         String refFieldName = '';

        for (String keyName : relationshipfieldMap.keySet()) {
                    soqlstr += keyName + ',';
                    refFieldName = keyName.replace('__c', '__r');
                    String valueName = relationshipfieldMap.get(keyName);
                    soqlstr += refFieldName + '.' + valueName + ',';
                }
        soqlstr = soqlstr.subString(0, soqlstr.length() - 1);

        return soqlstr;

    }

    //Formatting Map Key and Value to JSON Body
    public HttpRequestService setRequestBody(Map<String, Object> mainsObject){
        String requestbody  = JSON.Serialize(mainsObject);
        requestbody = requestbody.replace('\\"', '"');
        requestbody = requestbody.replace('"[', '[');
        requestbody = requestbody.replace(']"', ']');
        requestbody = requestbody.replace('"{', '{');
        requestbody = requestbody.replace('}"', '}');
        requestbody = requestbody.replace('}', '}]');
        requestbody = requestbody.replace('{', '[{');
        this.request.setBody(requestbody);

        return this;
    }

    public HttpRequestService setRequestBody(List<Map<String, Object>> mainsObject){
        String requestbody  = JSON.Serialize(mainsObject);
        requestbody = requestbody.replace('\\"', '"');
        requestbody = requestbody.replace('"[', '[');
        requestbody = requestbody.replace(']"', ']');
        requestbody = requestbody.replace('"{', '{');
        requestbody = requestbody.replace('}"', '}');
        // requestbody = requestbody.replace('}', '}]');
        // requestbody = requestbody.replace('{', '[{');
        this.request.setBody(requestbody);

        return this;
    }

    //Formatting Map Key and Value to JSON Body
    public HttpRequestService setSingleRequestBody(Map<String, Object> mainsObject){
        String requestbody  = JSON.Serialize(mainsObject);
        requestbody = requestbody.replace('\\"', '"');
        requestbody = requestbody.replace('"[', '[');
        requestbody = requestbody.replace(']"', ']');
        requestbody = requestbody.replace('"{', '{');
        requestbody = requestbody.replace('}"', '}');
        requestbody = requestbody.replace('}', '}]');
        requestbody = requestbody.replace('{', '[{');
        requestbody = requestbody.substring(1, requestbody.length()-1);
        this.request.setBody(requestbody);
        // System.debug('Request: ' + requestbody);
        return this;
    }

    public HttpRequestService setSingleRequestBodyWithoutReplacing(Map<String, Object> mainsObject){
        String requestbody  = JSON.Serialize(mainsObject);
        requestbody = requestbody.replace('\\"', '"');
        requestbody = requestbody.replace('"[', '[');
        requestbody = requestbody.replace(']"', ']');
        requestbody = requestbody.replace('"{', '{');
        requestbody = requestbody.replace('}"', '}');
        // requestbody = requestbody.replace('}', '}]');
        // requestbody = requestbody.replace('{', '[{');
        // requestbody = requestbody.substring(1, requestbody.length()-1);
        this.request.setBody(requestbody);
        // System.debug('Request: ' + requestbody);
        return this;
    }

    public HttpRequestService setRequestBodyJSONString(String jsonString){
        this.request.setBody(jsonString);
        // System.debug('HttpRequestBody: ' + jsonString);
        return this;
    }

    // End Utilities Methods Section



    // Start Setting Methods

    public HttpRequestService(){
        this.headers = new Map<String, String>();
        this.parameters = new Map<String,Object>();
        this.DestinationList = new List<String>();
        this.SendToSAP = false;
        this.request = new HttpRequest();
    }

    public HttpRequestService setHeader(String paratmetername, String value) {
       this.request.setHeader(paratmetername, value);
        return this;
    }

    public HttpRequestService setHeaders(Map<String, String> headers) {

        this.headers.putAll(headers);
        return this;
    }

    public HttpRequestService setParameter(String key, String value) {
        this.setParameters(new Map<String, String>{key => value});
        return this;
    }

    public HttpRequestService setParameters(Map<String, Object> parameters) {
        this.parameters.putAll(parameters);
        return this;
    }

    public HttpRequestService setTimeout(Integer timeoutMs) {
        this.request.setTimeout(timeoutMs);
        return this;
    }

    public String getBody(){
        return this.request.getbody();
    }

    // End Setting Methods

    //Callout Method
    public HttpResponse executeCallout(String httpVerb, String customEndPoint) {
        this.request.setMethod(httpVerb);
        this.request.setEndPoint(customEndPoint);
        
        System.debug(this.request.getbody());

        HttpResponse response;
        if(!Test.isRunningTest()) {
            response = new Http().send(this.request);
        }else {
            response = new CustomerCalloutMock().respond(this.request);
        }
        return response;
    }
}