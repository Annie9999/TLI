public class INS_VehicleListController {
    @AuraEnabled
    public static List<InsurancePolicyAsset> getVehicles(String policyId) {
        return [SELECT Id, CustomerPropertyId, InsurancePolicyId, CustomerProperty.Make, CustomerProperty.MakeYear, CustomerProperty.RegistrationNumber, CustomerProperty.ModelName,CustomerProperty.Name, CustomerProperty.OdometerReading, CustomerProperty.Property_Type__c, CustomerProperty.TransmissionType, CustomerProperty.Vin, CustomerProperty.INS_Make_Logo__c  
                FROM InsurancePolicyAsset 
                WHERE InsurancePolicyId = :policyId
                AND CustomerProperty.Property_Type__c = 'Vehicle'
                ORDER BY Name ];
    }
    
    @AuraEnabled
    public static CustomerProperty getVehicle(String vehicleId) {
        return [ SELECT Id, Name, Make, MakeYear, ModelName, OdometerReading, RegistrationNumber, Property_Type__c, TransmissionType, Vin, INS_Make_Logo__c 
                 FROM CustomerProperty
                 WHERE Id = :vehicleId 
                 AND Property_Type__c = 'Vehicle'];
    }
}