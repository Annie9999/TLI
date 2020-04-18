public class LiveChatTranscriptTriggerHandler {
    public static Id CC_CASE_QUEUE_ID {get{
        if(CC_CASE_QUEUE_ID==null){
            CC_CASE_QUEUE_ID = [SELECT Id, Name, DeveloperName,type FROM Group where DeveloperName = 'CC_Insured_Info_Service' and type ='Queue'].Id;
        }
        return CC_CASE_QUEUE_ID;
    }set;}

    public static void handleAfterUpdate(List<LiveChatTranscript> TriggerNew) {
        List<Id> ListLiveChatTranscriptId = new List<Id>();
    	for (LiveChatTranscript newObj : TriggerNew) {
        	ListLiveChatTranscriptId.add(newObj.Id);
    	}
    	system.debug(ListLiveChatTranscriptId);
    
    	List<LiveChatTranscript> ListLiveChatTranscript = [
        	SELECT Id, Name, ContactId, LeadId, CaseId, AccountId, Status 
        	FROM LiveChatTranscript 
        	WHERE Id IN :ListLiveChatTranscriptId AND Status = 'Missed'];
    	system.debug(ListLiveChatTranscript);
    
    	List<Case> ListCase = new List<Case>();
    	if(!ListLiveChatTranscript.isEmpty()){
        	List<Id> ListCaseId = new List<Id>();
        	for(LiveChatTranscript obj : ListLiveChatTranscript){
            	ListCaseId.add(obj.CaseId);
        	}
        	system.debug(ListCaseId);
        	ListCase = [SELECT Id, OwnerId FROM Case WHERE Id IN :ListCaseId];
        	system.debug(ListCase);
    	}
    
    	if(!ListCase.isEmpty()){
        	List<Case> ChangedListCase = new List<Case>();
        	Id QId = [SELECT Id, QueueId, Queue.Name, SobjectType FROM QueueSobject WHERE Queue.Name = 'CC ศูนย์บริการข้อมูลผู้เอาประกัน'].QueueId;
        	system.debug(QId);
        	for(Case obj : ListCase){
            	obj.OwnerId = QId;
            	ChangedListCase.add(obj);
        	}
        	system.debug(ChangedListCase);
        	if(!ChangedListCase.isEmpty()){
            	update ChangedListCase;
        	}
    	}
    }

}