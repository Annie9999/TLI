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
        
        List<Opportunity> opp = [SELECT Account.FirstName,Account.LastName, Id, Name,StageName,Approval_Status__c      
                                   FROM Opportunity   
                                   where  StageName =: 'Closed Reject' and Approval_Status__c  =: 'UW ปฏิเสธ'   and id =: oppty.Id  ];
        
        
        Opportunity newOpp = new Opportunity();
        
     //   System.debug('oppty: ' +opp.StageName);
      //  System.debug('oppty: ' +opp.Approval_Status__c);

        if(!opp.isEmpty()){
            Datetime today = system.Now().addDays(30);
            String Name = oppty.Account.FirstName +' '+ oppty.Account.LastName;
            //newOpp.SourceId   = oppty.Id;
            newOpp.LeadSource = 'เสนอผลิตภัณฑ์ใหม่ให้ผู้มุ่งหวัง';
            newOpp.AccountId = oppty.AccountId;
            newOpp.Name = Name+'สนใจอีกครั้ง' ;
            newOpp.StageName  = 'ความสนใจ';
            newOpp.CloseDate  = today.date();
            insert newOpp;
            return newOpp.Id;
            
        }else{
            
            
            return null;
            
        }
        
        
        
       /*Opportunity newOpp = new Opportunity();
        
        if(opp.StageName == 'Closed Reject' && opp.Approval_Status__c  == 'UW ปฏิเสธ'){
            Datetime today = system.Now().addDays(30);
            String Name = oppty.Account.FirstName +' '+ oppty.Account.LastName;
            //newOpp.SourceId   = oppty.Id;
            newOpp.LeadSource = 'เสนอผลิตภัณฑ์ใหม่ให้ผู้มุ่งหวัง';
            newOpp.AccountId = oppty.AccountId;
            newOpp.Name = Name+'สนใจอีกครั้ง' ;
            newOpp.StageName  = 'ความสนใจ';
            newOpp.CloseDate  = today.date();
            insert newOpp;

        }else{
            newOpp.Id = null;
        }
            
            return newOpp;*/
            
      

                
                
                
                
                
        
       /* if(opp.StageName == 'Closed Reject' && opp.Approval_Status__c  == 'UW ปฏิเสธ'){
            Datetime today = system.Now().addDays(30);
            String Name = oppty.Account.FirstName +' '+ oppty.Account.LastName;
            //newOpp.SourceId   = oppty.Id;
            newOpp.LeadSource = 'เสนอผลิตภัณฑ์ใหม่ให้ผู้มุ่งหวัง';
            newOpp.AccountId = oppty.AccountId;
            newOpp.Name = Name+'สนใจอีกครั้ง' ;
            newOpp.StageName  = 'ความสนใจ';
            newOpp.CloseDate  = today.date();

        }else{
            
        }
        
                    insert newOpp;*/

    
        
        
		/*if(opp.StageName)*/
        
        
        
		/*Datetime today = system.Now().addDays(30);
		String Name = oppty.Account.FirstName +' '+ oppty.Account.LastName;
        Opportunity newOpp = new Opportunity();
        //newOpp.SourceId   = oppty.Id;
        newOpp.LeadSource = 'เสนอผลิตภัณฑ์ใหม่ให้ผู้มุ่งหวัง';
        newOpp.AccountId = oppty.AccountId;
        newOpp.Name = Name+'สนใจอีกครั้ง' ;
        newOpp.StageName  = 'ความสนใจ';
 		newOpp.CloseDate  = today.date();
        insert newOpp;*/
        

        
    }


}