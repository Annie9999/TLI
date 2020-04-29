public class DescribeDataCategoryGroupStructures {
    public class DataCategories{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public Boolean expanded{get;set;}
        @AuraEnabled
        public List<DataCategories> items{get;set;}
    }
    public class Items{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public Boolean expanded{get;set;}
    }

    @AuraEnabled
    public static List<DataCategories> getDescribeDataCategoryGroupStructureResults(){
        List<DataCategories> lstKm = new List<DataCategories>();

        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        try {
            List<String> objType = new List<String>();
            objType.add('KnowledgeArticleVersion');
            describeCategoryResult = Schema.describeDataCategoryGroups(objType);
            System.debug('chema.describeDataCategoryGroups : ' + describeCategoryResult);
            List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
            
            for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
                DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                p.setSobject(singleResult.getSobject());
                p.setDataCategoryGroupName(singleResult.getName());
                pairs.add(p);
                System.debug('DataCategoryGroupSobjectTypePair : '+p);
                System.debug('List<DataCategoryGroupSobjectTypePair> : '+pairs);
            }
          
            describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
            System.debug('chema.Schema.describeDataCategoryGroupStructures : ' + describeCategoryStructureResult);
            for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
                DataCategories km = new DataCategories();

                singleResult.getSobject();
                singleResult.getName();
                singleResult.getLabel();
                singleResult.getDescription();

                km.label = singleResult.getLabel();
                km.name = singleResult.getName();
                km.expanded = true;

                System.debug('singleResult : '+singleResult);
                System.debug('singleResult.getSobject() : '+singleResult.getSobject());
                System.debug('singleResult.getName() : '+singleResult.getName());
                System.debug('singleResult.getLabel() : '+singleResult.getLabel());
                System.debug('singleResult.getDescription() : '+singleResult.getDescription());
    
                DataCategory [] toplevelCategories =  singleResult.getTopCategories();
                
                List<DataCategory> allCategories =  getAllCategories(toplevelCategories);
    
                for(DataCategory category : allCategories) {
                    DataCategories kmItem = new DataCategories();
                    System.debug('allCategories : '+category);
                    System.debug('allCategories Name : '+category.getName());
                    System.debug('allCategories Label : '+category.getLabel());
                    category.getName();
                    category.getLabel();

                    kmItem.name = category.getName();
                    kmItem.label = category.getLabel();
                    kmItem.expanded  = true;
                    (km.items).add(kmItem);

                    DataCategory [] childCategories = category.getChildCategories();
                }
                // km.items = lstKmItem;
                lstKm.add(km);
            }
       } catch (Exception e){
            System.debug('ERROR : ' + e.getMessage());
       }
       System.debug('Data cate => ' + describeCategoryStructureResult);
       return lstKm;
     }

    public static DataCategory[] getAllCategories(DataCategory [] categories){
       if(categories.isEmpty()){
            return new DataCategory[]{};
       } 
       else {
            DataCategory [] categoriesClone = categories.clone();
            DataCategory category = categoriesClone[0];
            DataCategory[] allCategories = new DataCategory[]{category};
            categoriesClone.remove(0);
            categoriesClone.addAll(category.getChildCategories());
            allCategories.addAll(getAllCategories(categoriesClone));
            return allCategories;
       }
    }

    public static DataCategories[] getAllCategoriesTemp(DataCategories [] items){
        if(items.isEmpty()){
            return new DataCategories[]{};
        }
        else{
            List<DataCategories> items_temp = items.clone();
            DataCategories item = items_temp.get(0);
            List<DataCategories> items_temp_2 = new List<DataCategories>();
            items_temp_2.add(item);
            items_temp.remove(0);
            // items_temp.addAll(item.getAllCategories(items_temp));
            return items_temp;
        }
    }
 }