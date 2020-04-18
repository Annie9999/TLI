trigger OpportunityTrigger on Opportunity (before update,after update) {

    if(trigger.isUpdate && trigger.isBefore){
        for (Opportunity item : Trigger.New){
            System.debug('status Kanut new Before '+item.StageName);
        }
        for (Opportunity item2 : Trigger.Old){
            System.debug('status Kanut old Before '+item2.StageName);
        }
    }
    
    if(trigger.isUpdate && trigger.isAfter){
        for (Opportunity item : Trigger.New){
            System.debug('status Kanut new After '+item.StageName);
        }
        for (Opportunity item2 : Trigger.Old){
            System.debug('status Kanut old After '+item2.StageName);
        }
    }

}