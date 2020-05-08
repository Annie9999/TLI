public with sharing class TLI_ReceiveLeadBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    BusinessHours bh;
    Datetime dtnow;

    public TLI_ReceiveLeadBatch() {
        bh = [SELECT Id FROM BusinessHours WHERE Name='LMS Business Hours'];
        dtnow = Datetime.now();
        // Datetime now = Datetime.now();
        // Integer slaHours = 2;
        // Datetime targetTime = BusinessHours.addGmt(bh.Id, now, slaHours* 60 * 60 * 1000L);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,SLA__c,Status FROM Lead WHERE Status IN ('รับงานแล้ว','นัดพบลูกค้า','ไปเจอลูกค้า') AND SLA__c <= :dtnow]);
    }

   public void execute(Database.BatchableContext BC,List<sObject> scope){
        for(sObject s : scope){
            System.debug((Lead)s);
        }
    }
    public void finish(Database.BatchableContext BC){
        System.debug('Finish');
    }
    
}