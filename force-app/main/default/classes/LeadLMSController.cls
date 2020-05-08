public without sharing class LeadLMSController {

    @AuraEnabled(cacheable=true)
    public static List<LeadObject> getLeadList() {
        List<Lead> leads= [ SELECT Id, Name, SLA__c, Rating, OwnerId, Status 
                            FROM Lead 
                            WHERE OwnerId =: UserInfo.getUserId()
                            AND SLA__c != null 
                            AND SLA__c >: Datetime.now()
                            AND (Status = 'ยืนยันการรับงาน' OR Status = 'รอเข้าพบลูกค้า')
                            ORDER BY SLA__c 
                            LIMIT 5];
                            
        List<LeadObject> leadObjList = new List<LeadObject>();
        leadObjList = remainingTime(leads);   
        System.debug('leadObjList: ' +leadObjList);
        System.debug('leads: ' +leads);
        return leadObjList;
    }

    public static List<LeadObject> remainingTime(List<Lead> leads){

        List<LeadObject> leadObjList = new List<LeadObject>(); 
        BusinessHours bh = [SELECT Id,MondayStartTime, MondayEndTime FROM BusinessHours WHERE Name='LMS Business Hours'];
        Datetime now = Datetime.now();
        Integer workHours = 9;
        Integer indexCount = 1;
        for (Lead lead : leads) {
            Long milliseconds = BusinessHours.diff(bh.Id, now, lead.SLA__c);
            Long minutes = milliseconds/(60*1000L);
            Long hours = minutes/60;
            Long days = hours/workHours;
            Long remainingHours = hours - (days*workHours);
            Long remainingMins = (minutes-(workHours*days*60)) - (remainingHours*60);
            String totalTime = String.valueOf(days) + ' วัน ' + String.valueOf(remainingHours) + ' ชม. ' +  String.valueOf(remainingMins) +' นาที';
            System.debug('totalTime : ' + totalTime);

            LeadObject leadObj = new LeadObject(); 
            leadObj.lead = lead;
            leadObj.remainingTime = totalTime;
            leadObj.leadUrl = 'https://thailife--tlifull.lightning.force.com/lightning/r/Lead/' + lead.Id +'/view';
            leadObj.taskPercentage = lead.Status == 'ยืนยันการรับงาน' ? 33 : 66;
            leadObj.index = indexCount;
            leadObjList.add(leadObj);

            indexCount++;
        }
        return leadObjList;
    }

    public class LeadObject{
        @AuraEnabled public Lead lead {get;set;}
        @AuraEnabled public String remainingTime {get;set;}       
        @AuraEnabled public String leadUrl {get;set;}      
        @AuraEnabled public Integer taskPercentage {get;set;}
        @AuraEnabled public Integer index {get;set;}       
    }   
}