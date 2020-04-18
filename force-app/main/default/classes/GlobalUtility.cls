public class GlobalUtility {

    public static Map<String, Map<String, String>> recordTypeMapMapBySObject;

    public static Boolean abortScheduledJob(String containName) {
        containName = '%' + containName + '%';
        List<CronTrigger> jobList = [SELECT Id, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
                                     FROM CronTrigger WHERE CronJobDetail.Name LIKE :containName];

        if (jobList.isEmpty()) {
            //AppLogger.debug('GlobalUtility', 'abortScheduledJob', containName, containName + ' not found', null);
        }

        Boolean hasAbort = false;
        for (CronTrigger job : jobList) {
            if (job != null && job.Id != null) {
                System.abortJob(job.Id);
                hasAbort = true;
            }
        }
        return hasAbort;
    }
    
    public static Boolean abortScheduledJob(String containName, String state) {
        containName = '%' + containName + '%';
        List<CronTrigger> jobList = [SELECT Id, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
                                     FROM CronTrigger WHERE CronJobDetail.Name LIKE :containName AND State = :state];

        if (jobList.isEmpty()) {
            //AppLogger.debug('GlobalUtility', 'abortScheduledJob', containName, containName + ' not found', null);
        }

        Boolean hasAbort = false;
        for (CronTrigger job : jobList) {
            if (job != null && job.Id != null) {
                System.abortJob(job.Id);
                hasAbort = true;
            }
        }
        return hasAbort;
    }

    private static Map<String, Map<String, Id>> getRecordTypeIdMapByDevName() {
        if (GlobalUtility.recordTypeMapMapBySObject == null) {
            GlobalUtility.recordTypeMapMapBySObject = new Map<String, Map<String, Id>>();
            Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, DeveloperName, SObjectType FROM RecordType]);
            for (RecordType eachRecordType : recordTypeMap.values()) {
                if (GlobalUtility.recordTypeMapMapBySObject.containsKey(eachRecordType.SObjectType)) {
                    GlobalUtility.recordTypeMapMapBySObject.get(eachRecordType.SObjectType).put(eachRecordType.DeveloperName, eachRecordType.Id);
                } else {
                    GlobalUtility.recordTypeMapMapBySObject.put(eachRecordType.SObjectType, new Map<String, Id> {eachRecordType.DeveloperName => eachRecordType.Id});
                }
            }
        }

        return GlobalUtility.recordTypeMapMapBySObject;
    }
    
    public static Id getRecordTypeIdFromSObjectByDevName(String sObjectName, String recordTypeDevName) {
        GlobalUtility.recordTypeMapMapBySObject = getRecordTypeIdMapByDevName();
        Map<String, Id> resultsMap = GlobalUtility.recordTypeMapMapBySObject.get(sObjectName);
        return resultsMap.get(recordTypeDevName);
    }

    private static User currentUser;
    public static User getCurrentUser() {
        if(currentUser == null){
		    currentUser = [SELECT Id, Name, Username, Profile.Name, Profile.UserLicense.Name, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        }
		return currentUser;
	}
    
    public static String getDescribedObjects( List<String> lstSObjectType ) {
    	
        // Globally desribe all the objects 
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        // Create a JSON string with object field labels and picklist values
        String allObjJSON = '{';
        
        // Iterate over the list of objects and describe each object  
        for( String sObjectType : lstSObjectType ) {
            
            if( allObjJSON != '{' ) 
            	allObjJSON += ', ';
            allObjJSON += '"' + sObjectType + '": ';
            DescribeSObjectResult describeResult = globalDescribe.get(sObjectType).getDescribe();
            Map<String, Schema.SObjectField> desribedFields = describeResult.fields.getMap();
            String objJSON = '{';
            
            for( String fieldName :  desribedFields.keySet() ) {
                
                // Descirbe the field 
                Schema.SObjectField field = desribedFields.get( fieldName );
                Schema.DescribeFieldResult f = field.getDescribe();	   
                if( objJSON != '{' )
                    objJSON += ', ';    
                // Get the field label and append in the JSON string
                objJSON += '"' + f.getName() + '": ' + '{ "label" : "' + f.getLabel() + '"';
                
                // if it's a picklist field then also add the picklist options
                if( field.getDescribe().getType() == Schema.DisplayType.PICKLIST ){
                    
                    List <Schema.PicklistEntry> picklistValues = field.getDescribe().getPickListValues();
                	List<String> pickListOptions = new List<String>();
                    pickListOptions.add('{ "label": "--None--", "value": null }');
                    
                    for (Schema.PicklistEntry pe : picklistValues) { 
                        
                        pickListOptions.add('{ "label": "' + pe.getLabel() + '", "value": "' + pe.getValue() + '" }');
                    
                    }
                    
                    System.debug( '>>>> ' + fieldName + '>>>> ' + String.join(pickListOptions, ', ') );
                    objJSON += ', "picklistOptions": [' + String.join(pickListOptions, ', ') + ']';   
                }
                objJSON += '}';
            }
            objJSON += '}';
            
            allObjJSON += objJSON;
        }
        
        // Close the object in the JSON String
        allObjJSON += '}';
        
        System.debug( ' JSON STRING : ' + allObjJSON );
        
        return allObjJSON;
    }
}