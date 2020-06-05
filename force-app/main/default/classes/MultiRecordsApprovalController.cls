public class MultiRecordsApprovalController {
    
    //Wrapper class to store the column values of data table
    public class SubmittedRecordsWrapper{
        @AuraEnabled public Id workItemId;
        @AuraEnabled public String recordId;
        @AuraEnabled public String relatedTo;
        @AuraEnabled public String recordName;
        @AuraEnabled public String submittedBy;
        @AuraEnabled public String submittercomment;
        @AuraEnabled public Date submittedDate;
        @AuraEnabled public String comments;
    }
    @AuraEnabled (cacheable=true)
    public static integer gettotalcount()
    {
        Integer icount = 0;
        for(ProcessInstance ps : [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                                 (SELECT ID FROM WorkItems WHERE OriginalActorId = : UserInfo.getUserId()) FROM ProcessInstance]){
            if(!ps.WorkItems.isEmpty()){
                icount++;
            }
        }
        return icount;
    }
    @AuraEnabled
    public static List<SubmittedRecordsWrapper> getSubmittedRecords(Integer queryLimit, Integer queryOffset){
        system.debug('queryLimit'+queryLimit);
        system.debug('queryOffset'+queryOffset);
        List<SubmittedRecordsWrapper> lstSubmissionWrapper = new List<SubmittedRecordsWrapper>();
        //Process instance stores the info of records submitted for approval,
        // Process instance work item are the records an approver sees while approving/rejecting, Process instance step stores approved/rejected record including approva;/rejection comments
        for(ProcessInstance ps : [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                                 (SELECT ID FROM WorkItems WHERE OriginalActorId = : UserInfo.getUserId()),
                                 (SELECT OriginalActor.Name,Comments FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance
                                 ORDER BY CreatedDate DESC LIMIT :queryLimit OFFSET :queryOffset]){
            if(!ps.WorkItems.isEmpty()){
                SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();
                objSubmittedRecordsWrapper.workItemId = ps.WorkItems[0].Id;
                objSubmittedRecordsWrapper.recordId = ps.TargetObjectId;
                objSubmittedRecordsWrapper.recordName = ps.TargetObject.Name;
                objSubmittedRecordsWrapper.comments = '';
                objSubmittedRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);//get the object name using the record id
                objSubmittedRecordsWrapper.submittedDate = Date.newInstance(ps.CreatedDate.year(),ps.CreatedDate.month(),ps.CreatedDate.day());
                if(!ps.steps.isEmpty()){
                    objSubmittedRecordsWrapper.submittedBy = ps.steps[0].OriginalActor.Name;
                    if(ps.steps[0].Comments == '' || ps.steps[0].Comments == null)
                    objSubmittedRecordsWrapper.submittercomment = 'No comments from submitter';
                    else
                    objSubmittedRecordsWrapper.submittercomment = ps.steps[0].Comments;
                    lstSubmissionWrapper.add(objSubmittedRecordsWrapper);
                }
            }
        }
        system.debug(lstSubmissionWrapper.size());
        return lstSubmissionWrapper;
    }
    
    public static String getObjectName(String recordId){
        //To get the label of the object name using Schema methods
        String keyPrefix = recordId.subString(0,3);
        String objectName = '';
        Map<String,Schema.SObjectType> sobjectTypeMap = Schema.getGlobalDescribe();
        for(String obj : sobjectTypeMap.keySet()){
            Schema.DescribeSObjectResult sobjectResult = sobjectTypeMap.get(obj).getDescribe();
            if(sobjectResult.getKeyPrefix() == keyPrefix){
                objectName = sobjectResult.getLabel();
                break;
            }
        }
        return objectName;
    }
    
    @AuraEnabled
    public static String processRecords(String processType,String strwraprecs){
        system.debug('processType'+processType);
        system.debug('wraprecs'+strwraprecs);
        List<SubmittedRecordsWrapper> wraprecs = (List<SubmittedRecordsWrapper>)System.JSON.deserialize(strwraprecs, List<SubmittedRecordsWrapper>.class);
        Map<string,SubmittedRecordsWrapper> mapSubmittedRecordsWrapper = new map<String,SubmittedRecordsWrapper>();
        List<String> lstWorkItemIds = new List<String>();
        for(SubmittedRecordsWrapper iwrap: wraprecs)
        {
            mapSubmittedRecordsWrapper.put(iwrap.workItemId,iwrap);
            lstWorkItemIds.add(iwrap.workItemId);
        }
        
        //Approve,reject the record programmatically
        String message = ''; 
        Integer recordsProcessed = 0;
        String comments = processType == 'Approve' ? 'Approved' : 'Rejected';
        List<Approval.ProcessWorkitemRequest> lstWorkItemRequest = new List<Approval.ProcessWorkitemRequest>();//ProcessWorkitemRequest class has methods to programmatically process submitted records
        for(String workItemId : lstWorkItemIds){
            Approval.ProcessWorkitemRequest objWorkItemRequest = new Approval.ProcessWorkitemRequest();
            if(mapSubmittedRecordsWrapper.containsKey(workItemId))
                objWorkItemRequest.setComments(mapSubmittedRecordsWrapper.get(workItemId).comments);
            else
                objWorkItemRequest.setComments(comments);
            objWorkItemRequest.setAction(processType);//approve or reject
            objWorkItemRequest.setWorkitemId(workItemId);
            lstWorkItemRequest.add(objWorkItemRequest);
        }
        Approval.ProcessResult[] lstProcessResult = Approval.process(lstWorkItemRequest,FALSE);//process method is used for approving/rejecting records depending on setAction attribute
        for(Approval.ProcessResult processResult : lstProcessResult){
            if(processResult.isSuccess()){
                recordsProcessed++;
            }
            else{
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
}