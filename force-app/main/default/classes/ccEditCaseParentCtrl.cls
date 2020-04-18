public with sharing class ccEditCaseParentCtrl {

    public class Matrix{
        @AuraEnabled
        public List<Decimal> sla {get;set;}
        @AuraEnabled
        public Set<String> set_type {get;set;}
        @AuraEnabled
        public Set<String> set_topic {get;set;}
        @AuraEnabled
        public Set<String> set_subject {get;set;}
        @AuraEnabled
        public Set<String> set_subSubject {get;set;}
        @AuraEnabled
        public List<String> status {get;set;}
    }

    @AuraEnabled
    public static Set<String> topic {get;set;}
    @AuraEnabled
    public static Set<String> subject {get;set;}
    @AuraEnabled
    public static Set<String> sub_subject {get;set;}

    public ccEditCaseParentCtrl() {
        
    }

    @AuraEnabled
    public static Case getInfo(String recordId){
        Case editCase = [SELECT Id, ContactId, SourceId, AccountId, Status, Description, RecordTypeId, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA__c, TLI_Division__c, TLI_Subdivision__c, Origin FROM Case WHERE Id =: recordId];
        return editCase;
    }

    @AuraEnabled
    public static void save(String recordId,String contact,String source,String account, String status, String type, String topic,String subject, String sub_subject, String division, String subDivision, String origin, String description, String SLA){
        System.debug('recordId : ' + recordId);
        System.debug('contact : ' + contact);
        System.debug('source : ' + source);
        System.debug('account : ' + account);
        System.debug('status : ' + status);
        System.debug('type : ' + type);
        System.debug('topic : ' + topic);
        System.debug('subject : ' + subject);
        System.debug('sub_subject : ' + sub_subject);
        System.debug('division : ' + division);
        System.debug('subDivision : ' + subDivision);
        System.debug('origin : ' + origin);
        System.debug('description : ' + description);
        System.debug('SLA : ' + SLA);

        Case editCase = [SELECT Id, ContactId, SourceId, AccountId, OwnerId, Status, Description, RecordTypeId, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA__c, TLI_Division__c, TLI_Subdivision__c, Origin FROM Case WHERE Id =: recordId];

        editCase.ContactId = contact;
        editCase.SourceId = source;
        editCase.AccountId = account;
        // editCase.OwnerId = owner;
        editCase.Status = status;
        editCase.Service_Type__c = type;
        editCase.Service_Topic__c = topic;
        editCase.Service_Subject__c = subject;
        editCase.Service_Sub_Subject__c = sub_subject;
        editCase.TLI_Division__c = division;
        editCase.TLI_Subdivision__c = subDivision;
        editCase.Origin = origin;
        editCase.Description = description;

        

        System.debug('editCase.SLA__ : ' + SLA);
        editCase.SLA__c = Decimal.valueOf(SLA);

        update editCase;
    }

    // DYNAMIC FILTER
    // @AuraEnabled
    // public static Matrix filterMatrix(String topic, String subject, String subSubject){
    //     List<Service_Type_Matrix__c> listMatrix = new List<Service_Type_Matrix__c>();
    //     Matrix matrixData = new Matrix();
    //     matrixData.set_topic = new Set<String>();
    //     matrixData.set_subject = new Set<String>();
    //     matrixData.set_subSubject = new Set<String>();

    //     if(topic == null && subject == null && subSubject == null){
    //         listMatrix = [SELECT Id, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c];
    //         for(Service_Type_Matrix__c item : listMatrix){
    //             matrixData.set_topic.add(item.Service_Topic__c);
    //             matrixData.set_subject.add(item.Service_Subject__c);
    //             matrixData.set_subSubject.add(item.Service_Sub_Subject__c);
    //         }
    //     }
    //     else if(topic != null && subject == null && subSubject == null){
    //         listMatrix = [SELECT Id, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c WHERE Service_Topic__c =: topic];
    //         for(Service_Type_Matrix__c item : listMatrix){
    //             matrixData.set_subject.add(item.Service_Subject__c);
    //             matrixData.set_subSubject.add(item.Service_Sub_Subject__c);
    //         }
    //     }
    //     // else if(topic == null && subject != null && subSubject == null){
    //     //     listMatrix = [SELECT Id, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c WHERE Service_Topic__c =: topic];
    //     //     for(Service_Type_Matrix__c item : listMatrix){
    //     //         matrixData.set_topic.add(item.Service_Topic__c);
    //     //         matrixData.set_subSubject.add(item.Service_Sub_Subject__c);
    //     //     }
    //     // }
    //     // else if(topic == null && subject == null && subSubject != null){
    //     //     listMatrix = [SELECT Id, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c];
    //     //     for(Service_Type_Matrix__c item : listMatrix){
    //     //         matrixData.set_topic.add(item.Service_Topic__c);
    //     //         matrixData.set_subject.add(item.Service_Subject__c);
    //     //     }
    //     // }
    //     else if(topic != null && subject != null && subSubject == null){
    //         listMatrix = [SELECT Id, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c WHERE Service_Topic__c =: topic AND Service_Subject__c =: subject];
    //         for(Service_Type_Matrix__c item : listMatrix){
    //             matrixData.set_subSubject.add(item.Service_Sub_Subject__c);
    //         }
    //     }
    //     // else if(topic == null && subject != null && subSubject != null){
    //     //     listMatrix = [SELECT Id, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c];
    //     //     for(Service_Type_Matrix__c item : listMatrix){
    //     //         matrixData.set_topic.add(item.Service_Topic__c);
    //     //     }
    //     // }
    //     else if(topic != null && subject != null && subSubject != null){
    //         listMatrix = [SELECT Id, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c WHERE Service_Topic__c =: topic AND Service_Subject__c =: subject AND Service_Sub_Subject__c =: subSubject];
    //     }

    //     return matrixData;
    // }

    // get type 1
    @AuraEnabled
    public static Matrix filterMatrix_type(){
        List<Service_Type_Matrix__c> listMatrix = [SELECT Id, Name, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c];
        Matrix matrixData = new Matrix();
        matrixData.set_type = new Set<String>();
        matrixData.set_topic = new Set<String>();
        matrixData.set_subject = new Set<String>();
        matrixData.set_subSubject = new Set<String>();

        for(Service_Type_Matrix__c item : listMatrix){
            matrixData.set_type.add(item.Service_Type__c);
            matrixData.set_topic.add(item.Service_Topic__c);
            matrixData.set_subject.add(item.Service_Subject__c);
            matrixData.set_subSubject.add(item.Service_Sub_Subject__c);
        }
        return matrixData;
    }
    // get type to find topic 2
    @AuraEnabled
    public static Matrix filterMatrix_topic(String type){
        List<Service_Type_Matrix__c> listMatrix = new List<Service_Type_Matrix__c>();
        Matrix matrixData = new Matrix();
        matrixData.set_topic = new Set<String>();
        if(type != null){
            listMatrix = [SELECT Id, Name, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c WHERE Service_Type__c =: type];
            if(listMatrix.size()>0){
                for(Service_Type_Matrix__c item : listMatrix){
                    matrixData.set_topic.add(item.Service_Topic__c);
                }
                return matrixData;
            }
        }
        return null;
    }
    // get topic to find subject 3
    @AuraEnabled
    public static Matrix filterMatrix_subject(String type, String topic){
        List<Service_Type_Matrix__c> listMatrix = new List<Service_Type_Matrix__c>();
        Matrix matrixData = new Matrix();
        matrixData.set_subject = new Set<String>();
        if(type != null && topic != null){
            listMatrix = [SELECT Id, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c WHERE Service_Type__c =: type AND Service_Topic__c =: topic];
            if(listMatrix.size()>0){
                for(Service_Type_Matrix__c item : listMatrix){
                    matrixData.set_subject.add(item.Service_Subject__c);
                }
                return matrixData;
            }
        }
        return null;
    }
    // get topic,subject to find sub-subject 4
    @AuraEnabled
    public static Matrix filterMatrix_subSubject(String type, String topic, String subject){
        List<Service_Type_Matrix__c> listMatrix = new List<Service_Type_Matrix__c>();
        Matrix matrixData = new Matrix();
        matrixData.set_subSubject = new Set<String>();
        if(type != null && topic != null && subject != null){
            listMatrix = [SELECT Id, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c  WHERE Service_Type__c =: type AND Service_Topic__c =: topic AND Service_Subject__c =: subject ORDER BY CreatedDate];
            if(listMatrix.size()>0){
                matrixData.sla = new Decimal[]{listMatrix[0].SLA_min__c};
                for(Service_Type_Matrix__c item : listMatrix){
                    matrixData.set_subSubject.add(item.Service_Sub_Subject__c);
                }
                return matrixData;
            }
        }
        return null;
    }
    // get topic,subject,sub-subject to find SLA 5
    @AuraEnabled
    public static Matrix filterMatrix_sla(String type, String topic, String subject, String sub_subject){
        List<Service_Type_Matrix__c> listMatrix = new List<Service_Type_Matrix__c>();
        Matrix matrixData = new Matrix();
        if(topic != null && topic != null && subject != null){
            listMatrix = [SELECT Id, Service_Type__c, Service_Topic__c, Service_Subject__c, Service_Sub_Subject__c, SLA_min__c FROM Service_Type_Matrix__c  WHERE Service_Type__c =: type AND Service_Topic__c =: topic AND Service_Subject__c =: subject AND Service_Sub_Subject__c =: sub_subject ORDER BY CreatedDate];
            System.debug('SLA : ' + listMatrix);
            if(listMatrix.size()>0){
                matrixData.sla = new Decimal[]{listMatrix[0].SLA_min__c};
                System.debug('matrixData : ' + matrixData);
                return matrixData;
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static List<String> getPickListDivision(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.TLI_Division__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('picklist division : ' + pickListVal.getLabel());
		}     
		return pickListValuesList;
    }

    @AuraEnabled
    public static List<String> getPickListSubDivision(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.TLI_Subdivision__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('picklist SubDivision : ' + pickListVal.getLabel());
		}     
		return pickListValuesList;
    }

    @AuraEnabled
    public static List<String> getPickListOrigin(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.Origin.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('picklist Origin : ' + pickListVal.getLabel());
		}     
		return pickListValuesList;
    }

    @AuraEnabled
    public static List<String> getPickListStatus(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('picklist Status : ' + pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
}