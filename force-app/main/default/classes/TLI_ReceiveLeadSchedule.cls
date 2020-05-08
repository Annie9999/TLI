global with sharing class TLI_ReceiveLeadSchedule implements Schedulable{

    global void execute(SchedulableContext sc){
        Database.executeBatch(new TLI_ReceiveLeadBatch(),200);
    }
}