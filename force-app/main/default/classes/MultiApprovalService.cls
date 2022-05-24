/**
 * @author       Cleberson Barbosa das Chagas
 * @Description:  Service Class for get all records for approval
 * @Date:         11.04.2022
 *
 **/
public with sharing class MultiApprovalService {

    public String getObjectName(Id recordId){
        return recordId.getSObjectType().getDescribe().getLabel();
    }

  /**
    * @description Process records and build SubmittedRecordsWrapper
    * @param List<ProcessInstance>
    * @return List<SubmittedRecordsWrapper>
    */
    public Map<Id,SubmittedRecordsWrapper> builderWrapper(List<ProcessInstance> instances){
        Map<Id,SubmittedRecordsWrapper> submissionByTargetId = new Map<Id,SubmittedRecordsWrapper>();

        for(ProcessInstance ps : instances){
            if(!ps.WorkItems.isEmpty()){
                SubmittedRecordsWrapper submittedWrapper = new SubmittedRecordsWrapper(ps.WorkItems[0].Id, ps.TargetObjectId, ps.TargetObject.Name, getObjectName(ps.TargetObjectId), Date.newInstance(ps.CreatedDate.year(),ps.CreatedDate.month(),ps.CreatedDate.day()));
                if(!ps.steps.isEmpty()){
                    submittedWrapper.submittedBy = ps.steps[0].OriginalActor.Name;
                    submittedWrapper.submitterComments = 'No comments from submitter';
                    if(String.isNotEmpty(ps.steps[0].Comments)){
                        submittedWrapper.submitterComments = ps.steps[0].Comments;
                    }
                }
                submissionByTargetId.put(submittedWrapper.recordId, submittedWrapper);
            }
        }


        return submissionByTargetId;
    }

    /**
    * @description Mount dinamic select
    * @author Cleberson Barbosa | 05-11-2022 
    * @param Map<String String> filterByField 
    * @param List<String> columns 
    * @param String objectName 
    * @return String 
    **/
    public String mountSelect(Map<String, String> filterByField, List<String> columns, String objectName){
        String sel ='';
        if(columns!= null && !columns.isEmpty()){
            sel= String.format('Select {0} from {1} where Id in :ids ', new List<Object>{String.join(columns, ','), objectName});
        }else{
            sel= String.format('Select Id from {0} where Id in :ids ', new List<Object>{objectName});
        }
        if(filterByField != null && !filterByField.isEmpty()){
            String selc= '';
            for(String column : filterByField.keySet()){
                String item= filterByField.get(column);
                selc+= +' AND ' + column + '= '+ ('\''+ item+'\'' );
            }
            sel=sel + selc;
        }
        return (sel);
    }
}