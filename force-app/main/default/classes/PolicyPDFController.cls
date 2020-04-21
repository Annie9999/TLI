public class PolicyPDFController{
    public Id srcId {get;set;}
    // public Id getsrcId(){ return srcId; }
    // public void setsrcId(Id tempId){
    //     srcId = tempId;
    //     PolicyPDFController();
    // }

	public List<InsurancePolicy> Records {get; set;}
    
	public PolicyPDFController(){
        system.debug(srcId);
        system.debug(Records);
        Id SourceId = srcId;
		Records = [SELECT Id, Name FROM InsurancePolicy];
        system.debug(Records);
    }
    
    // public PolicyPDFController(){
        
    // }
}