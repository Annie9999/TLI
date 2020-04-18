public without sharing class getGroupController {
    
    @AuraEnabled 
    public static User getUserName(){
        QUEUE_NAME__mdt Queue_Name = [SELECT Queue_Name__c FROM QUEUE_NAME__mdt LIMIT 1]; 
        System.debug('Queue= '+Queue_Name.Queue_Name__c);
        Group groupId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name =: Queue_Name.Queue_Name__c  LIMIT 1];
        List<GroupMember> groupMB = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =:groupId.Id];
        integer randomInd = Integer.valueOf(Math.random() * groupMB.size());
        User user = [SELECT Id,Name FROM User WHERE id =: groupMB[randomInd].UserOrGroupId];
        System.debug(user);
        return user;
    }
    
    @AuraEnabled 
    public static string updateGroup(Id recordId,Id userId) {
        
        try {
           System.debug(recordId);
            System.debug(userId);
            Opportunity opp = new Opportunity(id=recordId);
            opp.OwnerId = userId;
            update opp;    
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}