public with sharing class MultiRecordsApprovalController {
    private static MultiApprovalService multiApprovalService;
    private static ProcessInstanceRepository processInstanceRepository;
    private static Map<String, String> statusApproval = new Map<String, String>{'Approve' => Label.Approval_Status_Approved, 'Reject' => Label.Approval_Status_Rejected};

    static{
        multiApprovalService= new MultiApprovalService();
        processInstanceRepository= new ProcessInstanceRepository();
    }
    /**
    * @description retrieve Columns and Filters used
    * @param metadataName
    * @return List<SubmittedRecordsWrapper>
    */
    @AuraEnabled(cacheable=true)
    public static FilterRegistries getColumnsAndFilters(String metadataName){
        return FilterRegistries.getInstance(metadataName);
    }

    /**
    * @description Retrieve total of registries for approval
    * @param String objecName
    * @return Integer
    */
    @AuraEnabled (cacheable=true)
    public static Integer gettotalcount(String objectName){
        return processInstanceRepository.countPendingApproval(UserInfo.getUserId(), statusApproval.values(), objectName);
    }

    /**
    * @description
    * @author Cleberson Barbosa | 05-10-2022
    * @param ProcessInstanceRepository.Pageable page
    * @param Map<String String> inputParams
    * @param String objectName
    * @param String columnsNames
    * @return List<SubmittedRecordsWrapper>
    **/
    @AuraEnabled
    public static List<SubmittedRecordsWrapper> filter(ProcessInstanceRepository.Pageable page, Map<String,String> inputParams, String objectName, String columnsNames){
        List<String> columns= columnsNames?.split(',');
        List<ProcessInstance> instances= String.isEmpty(objectName) ? processInstanceRepository.getStartedProcessByUserIdAndNotInStatusPageable(page, UserInfo.getUserId(),statusApproval.values())
        : processInstanceRepository.getStartedProcessByUserAndObjectNameAndNotInStatusPageable(page, UserInfo.getUserId(), objectName,statusApproval.values());

        Map<Id,SubmittedRecordsWrapper> submissionByTargetId= multiApprovalService.builderWrapper(instances);
        if(String.isNotBlank(objectName) && columns!= null && !columns.isEmpty()){
            List<SubmittedRecordsWrapper> toReturn=new List<SubmittedRecordsWrapper>();

            String query = multiApprovalService.mountSelect(inputParams, new List<String>(columns), objectName);

            Set<Id> ids = submissionByTargetId.keySet();

            Map<Id, SObject> objects= new Map<Id, SObject>(Database.query(query));

            for (Id id : objects.keySet()) {
                submissionByTargetId.get(id).obj=objects.get(id);
                toReturn.add(submissionByTargetId.get(id));
            }
            return toReturn;
        }

        return submissionByTargetId.values();
    }

    /**
    * @description  Process instance stores the info of records submitted for approval,
    *               Process instance work item are the records an approver sees while approving/rejecting,
    *               Process instance step stores approved/rejected record including approval/rejection comments
    * @author Cleberson Barbosa | 05-10-2022
    * @param String processType
    * @param List<SubmittedRecordsWrapper> strwraprecs
    * @return String
    **/
    @AuraEnabled
    public static String processRecords(String processType,List<SubmittedRecordsWrapper> strwraprecs){
        Map<string,SubmittedRecordsWrapper> mapSubmittedRecordsWrapper = new map<String,SubmittedRecordsWrapper>();
        List<String> lstWorkItemIds = new List<String>();
        for(SubmittedRecordsWrapper iwrap: strwraprecs){
            mapSubmittedRecordsWrapper.put(iwrap.workItemId,iwrap);
            lstWorkItemIds.add(iwrap.workItemId);
        }

        //Approve,reject the record programmatically
        String comments = statusApproval.get(processType);
        List<Approval.ProcessWorkitemRequest> lstWorkItemRequest = new List<Approval.ProcessWorkitemRequest>();//ProcessWorkitemRequest class has methods to programmatically process submitted records
        for(String workItemId : lstWorkItemIds){
            Approval.ProcessWorkitemRequest objWorkItemRequest = new Approval.ProcessWorkitemRequest();
            objWorkItemRequest.setComments(comments);
            if(mapSubmittedRecordsWrapper.containsKey(workItemId)){
                objWorkItemRequest.setComments(mapSubmittedRecordsWrapper.get(workItemId).comments);
            }
            objWorkItemRequest.setAction(processType);//approve or reject
            objWorkItemRequest.setWorkitemId(workItemId);
            lstWorkItemRequest.add(objWorkItemRequest);
        }
        Integer recordsProcessed = 0;
        String message = '';
        Approval.ProcessResult[] lstProcessResult = Approval.process(lstWorkItemRequest,false);//process method is used for approving/rejecting records depending on setAction attribute
        for(Approval.ProcessResult processResult : lstProcessResult){
            if(processResult.isSuccess()){
                recordsProcessed++;
            }else{
                for(Database.Error error : processResult.getErrors()){
                    message += error.getMessage();
                }
            }
        }
        if(recordsProcessed == lstWorkItemIds.size()){
            message = 'All records are '+comments+' successfully';
        }
        return message;
    }

    /**
    * @description method used for approve all records
    * @author Cleberson Barbosa | 05-18-2022
    * @param String objectName
    * @param String processType
    * @return String
    **/
    @AuraEnabled
    public static String proccessAllrecords(String objectName, String processType){
        processType= processType.split(' ')[0];
        Integer total= gettotalcount(objectName);
        ProcessInstanceRepository.Pageable page = new ProcessInstanceRepository.Pageable(total, '');
        List<SubmittedRecordsWrapper> wrapper = filter(page, null, objectName, null);
        return processRecords(processType, wrapper);
    }

}
