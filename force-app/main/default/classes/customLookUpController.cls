public class customLookUpController {
    public class lookupWrapper {
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public Map<String, String> extraValue{get;set;}
    }

    @AuraEnabled
    public static List < lookupWrapper > fetchLookUpValues(String searchKeyWord, String ObjectName, String nameField, String condition, String extraField, String extraSearchField, String customNameField, Boolean hasLastViewedDate, Boolean isSortNameField) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '';
        String sortKey = ' order by ';
        if (isSortNameField) {
            // searchKey = searchKeyWord + '%';
            sortKey += nameField + ' ASC, ';
        }

        if (hasLastViewedDate) {
            sortKey += ' LastViewedDate DESC NULLS LAST, ';
        }

        sortKey += ' createdDate DESC NULLS LAST';
        searchKey = '%' + searchKeyWord + '%';
      
        system.debug('Test' + nameField);
        system.debug('@condition->'+condition);
        List <lookupWrapper> returnList = new List <lookupWrapper> ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String searchCond = nameField + ' ';
        // String searchCond = ' where ' + nameField + ' LIKE: searchKey ';
        if(extraSearchField != '') {
            // searchCond = ' where ( ' + nameField + ' LIKE :searchKey OR ' + extraSearchField + ' LIKE :searchKey ) ';
            searchCond = '( ' + nameField + ' , ' + extraSearchField + ' ) ';
        }

        //SOSL by TK
        String sQuery = 'FIND \'' + searchKey + '\' IN ALL FIELDS RETURNING ' + ObjectName + '(' + searchCond + (extraField != ''? ',' + extraField: '') + (condition != ''? condition : '') + sortKey  + ' limit 5 )';
       
        System.debug('sQuery : ' + sQuery);
        //List < sObject > lstOfRecords = Database.query(sQuery);
        List<List<SObject>> lstOfRecords = search.query(sQuery);
        System.debug(lstOfRecords);
        List<String> relatedName = null;
        if(nameField.contains('.')){
            relatedName = nameField.split('\\.');
            System.debug(relatedName);
        }
        List<String> extraFields = extraField != ''? extraField.split(',') : null;
        for (List<sObject> lstOfRecords_List_obj : lstOfRecords) {
            for(sObject obj : lstOfRecords_List_obj) {
                lookupWrapper res = new lookupWrapper();
                res.Name = (relatedName != null && relatedName.size() == 2)? String.valueOf(obj.getSObject(relatedName[0]).get(relatedName[1])) : (String)obj.get(nameField);
                if(customNameField != '' && customNameField != null) {
                    List<String> cnfield = customNameField.split(',');
                    String innerName = (String) obj.get(cnfield.remove(0));
                    String desName = '';
                    for(String cname : cnfield) {
                        if(desName != ''){
                            desName += ' ';
                        }
                        desName += (String)obj.get(cname);
                    }
                    innerName += ' (' + desName + ')';
                    res.Name = innerName;
                }
                res.Id = obj.Id;
                res.extraValue = null;
                if(extraFields != null) {
                    res.extraValue = new Map<String, String>();
                    for(String fname : extraFields) {
                        res.extraValue.put(fname, String.valueOf(obj.get(fname)));
                    }
                }
                returnList.add(res);
            }
        }
        return returnList;
    }

    @AuraEnabled
    public static List<PicklistOption> getPicklistValue(String sobjectName, String fieldName) {
        List<PicklistOption> result = new List<PicklistOption>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult sObjectResult = gd.get(sobjectName).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjectResult.fields.getMap();

        Schema.SObjectField targetField = fieldMap.get(fieldName);
        List<Schema.PicklistEntry> ple = targetField.getDescribe().getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			result.add(new PicklistOption(pickListVal.getValue(), pickListVal.getLabel()));
		}     
		return result;
    }

}