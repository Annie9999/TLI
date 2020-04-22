public without sharing class CustomNewChildRecordListCtrl {

    public static Case parentCaseAllField {get;set;}

    public static Map<String,String> mapGroupQueue = new Map<String,String>();
    
    public static void mapGroupQueue(){ 
        List<Group> queryGroupQueue = [ select Id,Name from Group where Type = 'Queue' ];
        for( Group eachGroup : queryGroupQueue ){
            mapGroupQueue.put(eachGroup.Name,eachGroup.Id);//Queue_Name__c
        }      
    }
    public static String checkIdGroupQueue(String input){
        if( mapGroupQueue.containsKey(input) ){
            return mapGroupQueue.get(input);
        }                
        return '';
    }

    public CustomNewChildRecordListCtrl() {
        
    }
    @AuraEnabled
    public static Boolean createChildCase(List<ChildDetail> childList,Case parent) {
        List<Case> listInsertCase = new List<Case>();
        System.debug('parentCaseAllField : '+parent);
        mapGroupQueue();
        for(ChildDetail eachChild :childList){
            System.debug('checkIdGroupQueue() : '+checkIdGroupQueue(eachChild.TLI_Subdivision));

            Case childSet = new Case();
            childSet = parent.clone(false,true);
            childSet.ParentId = parent.Id;
            childSet.AccountId = eachChild.AccountId;
            childSet.Insurance_Policy__c = eachChild.InsurePolicy;
            childSet.TLI_Division__c = eachChild.TLI_Division;
            childSet.TLI_Subdivision__c = eachChild.TLI_Subdivision;
            childSet.Status = 'งานใหม่';
            if(checkIdGroupQueue(eachChild.TLI_Subdivision) != ''){
                childSet.OwnerId = checkIdGroupQueue(eachChild.TLI_Subdivision);
            }
            
            System.debug('childSet : '+childSet);
            listInsertCase.add(childSet);
        }
        insert listInsertCase;

        return true; 
    }

    @AuraEnabled
    public static Case caseInfoByParent(String Id) {
        parentCaseAllField = queryCaseFields(Id);
        return parentCaseAllField;
    }

    public static Case queryCaseFields(String caseId) {
        Case returnCase = new Case();
        try{
            String strQuery = 'select ';
            strQuery += queryAllField();
            strQuery = strQuery.substring(0,strQuery.length()-1);
            String strWhere = ' where Id = \''+caseId+'\'';
            strQuery += ' from Case ';
            strQuery += strWhere;
            System.debug('strQuery : '+strQuery);
            returnCase = Database.query(strQuery);
        }catch(Exception e){
           	System.debug('error : '+e.getMessage());
        }
        return returnCase;
    }

    public static String queryAllField() {
        String strQuery = '';
        List<String> q = new List<String>();
        Schema.DescribeSObjectResult r = Case.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Case.fields.getMap();
        
        for(string apiName : r.fields.getMap().keySet()){
            Schema.SObjectField field = M.get(apiName);
            if( !field.getDescribe().isCalculated() ){
                q.add(apiName);
            }           
        }
        for( String s : q ){
            strQuery += s+',';
        }
        System.debug('MTL_Utility queryAllField : '+strQuery);
        return strQuery;
    }
    
    @AuraEnabled
    public static InsurancePolicy findPolicy(String Id) {
        return [
            SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE NameInsuredId = :Id limit 1
        ];
    }
    
    public class ChildDetail {
        @AuraEnabled
        public String AccountId {get;set;}
        @AuraEnabled
        public String InsurePolicy {get;set;}
        @AuraEnabled
        public String TLI_Division {get;set;}
        @AuraEnabled
        public String TLI_Subdivision {get;set;}
    }
}