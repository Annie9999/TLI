global class Generate_GetAccountsToFollowUp {  
//NOTE: You can get the user id of the current user by also doing UserInfo.getUserId(). 
    @InvocableMethod(label='Refferral Friend test by JJ' 
                     description='Recommend accounts the current user should follow up on today for Refferral Friend')
    global static List<List<Recommendation>> getAccounts(List<String> inputData){
        List<List<Recommendation>> outputs = new List<List<Recommendation>>();
        Integer daysSinceLastContact;
        Account[] accounts = [SELECT Name, Description, PersonBirthdate,Customer_Age__c, OwnerId FROM Account WHERE Id = :inputData[0] ];
        List<Recommendation> recs = new List<Recommendation>(); 
        for (Account account:accounts) {
            //account.Customer_Age__c = 5;
            //if (account.Customer_Age__c  != null){
                    Recommendation rec = new Recommendation(
                        Name = account.Name,
                        Description = 'Connect with the ' + account.Name + ' account, Prefer Refferral Friend Campaign. As a customer '+account.Customer_Age__c+' year',
                        //Pre-req: Create a screen flow with the name simpleFlow                        
                        ActionReference = 'Ref_Flow',
                        AcceptanceLabel = 'Review'
                    );
            
            		
                    recs.add(rec);
               
            //}
        }
        /*for (Account account:accounts) {
            if (account.PersonBirthdate  != null){
                //daysSinceLastContact = account.PersonBirthdate.daysBetween(date.today());
                Date beforeDOB = account.PersonBirthdate.addDays(7);
                Boolean d = beforeDOB.isSameDay(date.today());
				system.debug('d='+d);
                if (d){
                    Recommendation rec = new Recommendation(
                        Name = account.Name,
                        Description = 'Connect with the ' + account.Name + ' account, Up-sell thee DM product woth discount in DOB campaign.',
                        //Pre-req: Create a screen flow with the name simpleFlow                        
                        ActionReference = 'ffff',
                        AcceptanceLabel = 'View'
                    );
                    recs.add(rec);
                }
            }
        }*/
        outputs.add(recs);
        system.debug('outputs='+outputs);
        return outputs; 
    }
}