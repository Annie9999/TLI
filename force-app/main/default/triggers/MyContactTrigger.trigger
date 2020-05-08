trigger MyContactTrigger on Contact (before insert, before update) {
  
    if(Trigger.isUpdate){
       Contact cc = new Contact(LastName='test trigger');
        insert cc;
    // Iterate through each event message.
    for (Contact ct : Trigger.New) {
         Contact oldCt = Trigger.oldMap.get(ct.Id);
         
        if(oldCt.Marital_Status__c == 'โสด' && ct.Marital_Status__c == 'สมรส'){
            ct.Get_Married__c = true;
          //  update ct;
        } 
    }
    }
}