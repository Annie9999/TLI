public class LeadTriggerHandler {
    public static void handleBeforeUpdate(List<Lead> newLead){
        for(Lead l : newLead){
            if(l.ACC_owner__c == null && !String.valueOf(l.OwnerId).startsWith('00G')){
                l.ACC_owner__c = l.OwnerId;
            }
        }
    }
}