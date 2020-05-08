trigger MyAccountTrigger on Account (before insert, before update) {
  
    if(Trigger.isUpdate){
     
    // Iterate through each event message.
    for (Account acc : Trigger.New) {
         Account oldAcc = Trigger.oldMap.get(acc.Id);
         
        if(oldAcc.Marital_Status__pc == 'โสด' && acc.Marital_Status__pc == 'สมรส'){
            acc.Get_Married__pc = true;
        }else if(oldAcc.Marital_Status__pc == 'สมรส' && acc.Marital_Status__pc == 'โสด'){
            acc.Get_Married__pc = false;
        }  
    }
    }
}