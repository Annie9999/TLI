global class Generate_GetInsurancePolicyToUpdate {
//NOTE: You can get the user id of the current user by also doing UserInfo.getUserId(). 
    @InvocableMethod(label='Insurance Policy to Update Address' 
                     description='Recommend insurance policies the current user should update client address info')
    global static List<List<Recommendation>> getCases(List<String>inputData){
        List<List<Recommendation>> outputs = new List<List<Recommendation>>();
        Integer insurancePolicyCount;
        Case[] cases = [SELECT Status,Service_Subject__c,Service_Topic__c,AccountId FROM Case 
                        WHERE ((Service_Type__c = 'สิทธิตามกรมธรรม์' AND Service_Subject__c='ที่อยู่' AND Service_Topic__c ='การเปลี่ยนแปลงที่ไม่กระทบเบี้ยประกัน' AND RecordTypeId='012q00000005iuxAAA') OR
                               (Service_Type__c = 'การใช้สิทธิตามกรมธรรม์' AND Service_Subject__c='เปลี่ยนแปลงที่อยู่ผู้เอาประกัน' AND Service_Topic__c = 'เปลี่ยนแปลงกรมธรรม์' AND RecordTypeId='012q00000005iv7AAA')) 
                          AND Status<>'ดำเนินการเรียบร้อย' AND Id=:inputData[0]];
        List<Recommendation> recs = new List<Recommendation>(); 
        for (Case item:cases) {
           InsurancePolicy[] insurancePolicies = [SELECT Id FROM InsurancePolicy WHERE NameInsuredId=:item.AccountId ];
            insurancePolicyCount = insurancePolicies.size();        
            Recommendation rec = new Recommendation(
                        Name = 'อำนวยความสะดวก',
                        Description = 'คุณลูกค้ามีกรมธรรม์ทั้งหมด '+insurancePolicyCount+' ฉบับ ต้องการเปลี่ยนแปลงที่อยู่ทั้งหมดมั้ยคะ/ครับ' 
                        //Pre-req: Create a screen flow with the name simpleFlow                        
                        ,ActionReference = 'Change_address_flow',
                        AcceptanceLabel = 'ใช่',
                  RejectionLabel = 'ไม่'
                    );
                    recs.add(rec);
                
            
        }
        outputs.add(recs);
        return outputs; 
    }
}