public class opptyController {
    @AuraEnabled
    public static Opportunity getOpportunity(string oppId) {
        System.debug('oppId' +oppId);
        Opportunity opp = new Opportunity();
        opp = [SELECT Account.FirstName,Account.LastName, Id, Name FROM Opportunity where id =: oppId];
        System.debug('opp' +opp);
        // System.debug('StageName: ' +opp.StageName);
        //System.debug('Approval_Status__c: ' +opp.Approval_Status__c);
        
        return opp;
    }
    
    @AuraEnabled
    public static Id saveOpportunity(Opportunity oppty) {
        
        List<Opportunity> oppList = [  SELECT Account.FirstName,Account.LastName, Id, Name,StageName,Approval_Status__c ,Opportunity__c 
                                                     FROM Opportunity   
                                                     where  StageName =: 'Closed Reject' and Approval_Status__c  =: 'UW ปฏิเสธ'   and id =: oppty.Id];
                
        //   System.debug('oppty: ' +opp.StageName);
        //  System.debug('oppty: ' +opp.Approval_Status__c);
        
        Opportunity newOpp = new Opportunity();
        
        if(!oppList.isEmpty()){
            Datetime today = system.Now().addDays(30);
            String Name = oppList[0].Account.FirstName +' '+ oppList[0].Account.LastName;
            newOpp.Opportunity__c   = oppList[0].Id;
            newOpp.LeadSource = 'เสนอผลิตภัณฑ์ใหม่ให้ผู้มุ่งหวัง';
            newOpp.AccountId = oppList[0].AccountId;
            newOpp.Name = Name+'สนใจอีกครั้ง' ;
            newOpp.StageName  = 'ความสนใจ';
            newOpp.CloseDate  = today.date();
            insert newOpp;
            return newOpp.Id;
            
        }else{
            
            
            return null;
            
        }
        
        
    }
    
    
}