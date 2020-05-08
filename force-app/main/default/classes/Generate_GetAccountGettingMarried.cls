global class Generate_GetAccountGettingMarried {

//NOTE: You can get the user id of the current user by also doing UserInfo.getUserId(). 
    @InvocableMethod(label='Get Married' 
                     description='Recommend the current user to suggest family product for the one getting married')
    global static List<List<Recommendation>> getAccounts(List<String> inputData){
        List<List<Recommendation>> outputs = new List<List<Recommendation>>();
     
        Account[] accounts = [SELECT Name, Description, Get_Married__pc FROM Account 
                              WHERE Get_Married__pc = true AND Id = :inputData[0] ];
        List<Recommendation> recs = new List<Recommendation>(); 
        for (Account account:accounts) {
          
                    Recommendation rec = new Recommendation(
                        Name = 'Suggest Family Product',
                        Description = '[คุณ '+account.Name+' เปลี่ยน Life Stage โสด->สมรส] แนะนำผลิตภัณฑ์ประกันชีวิตเพื่อการออม',
                        //Pre-req: Create a screen flow with the name simpleFlow                        
                        ActionReference = 'Get_Married',
                        AcceptanceLabel = 'แนะนำ',
                        RejectionLabel = 'ไม่แนะนำ'
                    );

                    recs.add(rec);
        }
        outputs.add(recs);
        system.debug('outputs='+outputs);
        return outputs; 
    
}
}