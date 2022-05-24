/**
 * @description       : Class used by Load cloumns, filter and options used in ApprovalcRecordFilters component LWC
 * @author            : Cleberson Barbosa
 * @group             : 
 * @last modified on  : 05-23-2022
 * @last modified by  : Cleberson Barbosa
**/
virtual public with sharing class FilterRegistries {

    @AuraEnabled public List<Column> columns{get; protected set;}
    @AuraEnabled public List<Filter> filters{get; protected set;}
    @AuraEnabled public List<String> columnsNames {get; protected set;}
    @AuraEnabled public String objectName{get; private set;}

    private List<Column> objectColumns {get; set;}
    public String metadataName{get;set;}

    private static FilterRegistries instance;
    private ProcessInstanceRepository processInstanceRepository;

    private FilterRegistries(){
        this.columns=(List<Column>)JSON.deserialize('[{"type":"button-icon","fixedWidth":40,"typeAttributes":{"iconName":"utility:preview","name":"view_record","title":"View Record","variant":"border-filled","alternativeText":"View Record","disabled":false}},{"type":"button-icon","fixedWidth":40,"typeAttributes":{"iconName":"utility:comments","name":"submitter_comments","title":"Submitter comments","variant":"border-filled","alternativeText":"Submitter comments","disabled":false}},{"label":"Item Name","fieldName":"recordName","type":"text","wrapText":true,"sortable":true},{"label":"Related to","fieldName":"relatedTo","type":"text","sortable":true},{"label":"Submitter","fieldName":"submittedBy","type":"text","sortable":true},{"label":"Submitted on","fieldName":"submittedDate","type":"date","typeAttributes":{"day":"numeric","month":"short","year":"numeric"},"sortable":true},{"label":"Approver Comment","fieldName":"comments","type":"text","wrapText":true,"editable":true}]', List<Column>.class);
        this.filters=new List<Filter>();
         this.objectColumns=new List<Column>();
        this.columnsNames=new List<String>();
        this.processInstanceRepository= new processInstanceRepository();
    }

    /**
    * @description
    * @author Cleberson Barbosa | 05-11-2022
    * @param String metadataName
    * @return FilterRegistries
    **/
    public static FilterRegistries getInstance(String metadataName){
        if(instance == null || !metadataName.equalsIgnoreCase(instance.metadataName)){
            instance= new FilterRegistries();
            instance.metadataName=metadataName;
            instance.getConfiguration(metadataName);
        }
        return instance;
    }

    /**
    * @description
    * @author Cleberson Barbosa | 05-11-2022
    * @param MassApprovalProcessAttribute__mdt metadata
    * @return List<Column>
    **/
    virtual public List<Column> populateColumns(MassApprovalProcessAttribute__mdt metadata){
        if(metadata.Parent_Object_Fields_API_Name__c !=null){
            List<String> fieldsNames = metadata.Parent_Object_Fields_API_Name__c.split(',');
            Map<String, Schema.SObjectField> fields= Schema.getGlobalDescribe().get(metadata.Parent_Object_API_Name__c).getDescribe().fields.getMap();
            Set<String> nameColumns = new Set<String>();
            for (String fieldName : fieldsNames) {
                if(fields.containsKey(fieldName)){
                    Schema.DescribeFieldResult fieldResult =fields.get(fieldName).getDescribe();
                    Column column= new Column();
                    column.fieldName=getReferenceField(fieldResult);
                    column.label=fieldResult.getLabel();
                    column.type=fieldResult.getType().name();
                    this.objectColumns.add(column);
                    nameColumns.add(column.fieldName);
                }
            }
            this.columnsNames.addAll(nameColumns);
            this.columns.addAll(objectColumns);
        }
        return this.columns;
    }

    /**
    * @description
    * @author Cleberson Barbosa | 05-11-2022
    * @param MassApprovalProcessAttribute__mdt metadata
    * @return List<Filter>
    **/
    virtual public List<Filter> populateFilters(MassApprovalProcessAttribute__mdt metadata){
        if(metadata.Child_Object_Fields_API_Name__c!=null){
            List<String> fieldsNames = metadata.Child_Object_Fields_API_Name__c.split(',');
            Map<String,Filter> filterByFieldName= new Map<String, Filter>();
            Map<String, Schema.SObjectField> fields= Schema.getGlobalDescribe().get(metadata.Parent_Object_API_Name__c).getDescribe().fields.getMap();
            for (String fieldName : fieldsNames) {
                if(fields.containsKey(fieldName)){
                    Schema.DescribeFieldResult fieldResult =fields.get(fieldName).getDescribe();
                    Filter filter = new Filter(getReferenceField(fieldResult), fieldResult.getLabel(), new Set<Options>());
                    filterByFieldName.put(filter.field, filter);
                }
            }
            MultiApprovalService service= new MultiApprovalService();
            String query = service.mountSelect(null, new List<String>(filterByFieldName.keySet()), objectName);
            List<ProcessInstanceWorkitem> items= processInstanceRepository.getInstanceWorkByUserAndStatus(UserInfo.getUserId(), String.escapeSingleQuotes('Pending'));
            List<Id> ids= new List<Id>();
            for(ProcessInstanceWorkitem item : items){
                ids.add(item.ProcessInstance.TargetObjectId);
            }

            List<Sobject> objects = Database.query(query);
            for(SObject obj : objects){
                Map<String, Object> populatedFields = obj.getPopulatedFieldsAsMap();
                for(String fieldName : populatedFields.keySet()){

                    if(filterByFieldName.containsKey(fieldName+'.Name')){
                        Filter filter =filterByFieldName.get(fieldName+'.Name');
                        filter.field=fieldName+'.Id';
                        filter.values.add(new Options(''+((SObject) populatedFields.get(fieldName)).get('Name'), ''+((SObject) populatedFields.get(fieldName)).get('Id')));
                    }else if(filterByFieldName.containsKey(fieldName)){
                            filterByFieldName.get(fieldName).values.add(new Options(''+obj.get(fieldName), ''+obj.get(fieldName)));
                    }
                }
            }
            this.filters.addAll(filterByFieldName.values());
        }
        return this.filters;
    }

    /**
    * @description
    * @author Cleberson Barbosa | 05-11-2022
    * @param String metadataName
    **/
    public void getConfiguration(String metadataName){
        MassApprovalProcessAttribute__mdt metadata = processInstanceRepository.getMetadata(metadataName).size() > 0?processInstanceRepository.getMetadata(metadataName).get(0): null;
        if(metadata?.Parent_Object_Fields_API_Name__c!= null){
            objectName= metadata.Parent_Object_API_Name__c;
            populateColumns(metadata);
            populateFilters(metadata);
        }
    }
    /**
    * @description
    * @author Cleberson Barbosa | 05-11-2022
    * @param Schema.DescribeFieldResult fieldResult
    * @return String
    **/
    private String getReferenceField(Schema.DescribeFieldResult fieldResult){
        if(fieldResult.getType()==Schema.DisplayType.REFERENCE){
            return fieldResult.getRelationshipName() + '.Name';
        }
        return fieldResult.getName();
    }

    public class Column{
        @AuraEnabled public String type{get;set;}
        @AuraEnabled public Integer fixedWidth{get;set;}
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String fieldName{get;set;}
        @AuraEnabled public Boolean wrapText{get;set;}
        @AuraEnabled public Boolean sortable{get;set;}
        @AuraEnabled public Boolean editable{get;set;}
        @AuraEnabled public TypeAttributes typeAttributes{get;set;}

        public Column(){
            type='text';
            fixedWidth=null;
            wrapText=true;
            sortable=true;
            editable=false;
            typeAttributes=null;
        }
    }

    public class TypeAttributes{
        @AuraEnabled public String iconName{get;set;}
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public String title{get;set;}
        @AuraEnabled public String variant{get;set;}
        @AuraEnabled public String alternativeText{get;set;}
        @AuraEnabled public Boolean disabled{get;set;}
    }

    public class Filter{
        @AuraEnabled public String field{get;set;}
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public Set<Options> values{get;set;}

        public Filter(String field, Set<String> values){
            this.field=field;
            this.values=new Set<Options>();
            for (String value : values) {
                this.values.add(new Options(value));
            }
        }
        public Filter(String field, String label, Set<Options> values){
            this.field=field;
            this.label=label;
            this.values=values;
        }
    }

    public class Options{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}
        public Options(String value){
            this.label=value;
            this.value=value;
        }

        public Options(String label, String value){
            this.label=label;
            this.value=value;
        }
        public Boolean equals(Object other) {
            return ((Options)other).value == this.value;
        }
        public Integer hashCode() {
            return this == null || this.value == null? 0 :
                   System.hashCode(this.value);
        }
    }

    public void setRepo(ProcessInstanceRepository processInstanceRepository){
        this.processInstanceRepository=processInstanceRepository;
    }

}
