public class CaseTriggerHandler {
    
    public static void handleBeforeUpdate(List<Case> TriggerNew){
        
        //Custom Metadata
        List<Case_Keyword__mdt> ListMetadata = [SELECT Id, Label, Keyword__c FROM Case_Keyword__mdt ORDER BY Label DESC];
        Map<String, Case_Keyword__mdt> MapMetadata = new Map<String, Case_Keyword__mdt>();
            for(Case_Keyword__mdt obj : ListMetadata){
                MapMetadata.put(obj.Label, obj);
            }
        system.debug(MapMetadata);
        
        List<String> ListKeyword = new List<String>();
        if(!ListMetadata.isEmpty()){
            for(Case_Keyword__mdt obj : ListMetadata){
                ListKeyword.add(obj.Keyword__c);
            }
            system.debug(ListKeyword);
        }
        
        for(Case newObj : TriggerNew){
            String SubjectString = newObj.Subject;
            for(String key : MapMetadata.keySet()){
                String keyword = MapMetadata.get(key).Keyword__c;
                if(SubjectString.contains(keyword) && newObj.Origin == 'Email'){
                    // Case add 'การ' to subject
                    if(key == 'Case1'){
                        String tempSubject = 'การ' + keyword;
                        String resultSubject = SubjectString.replace(keyword,tempSubject);
                        newObj.Subject = resultSubject;
                    }
                }
            }
        }
    }
    
}