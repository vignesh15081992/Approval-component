/**
 * @description       : Class used for execute actions in database
 * @author            : Cleberson Barbosa
 * @created           : 04-11-2022
 * @last modified on  : 05-23-2022
 * @last modified by  : Cleberson Barbosa
**/
virtual public with sharing class ProcessInstanceRepository {
   /**
    * @Description:  Class used for wrapper options for retrieve pageable objects
    *
    **/
    public class Pageable{
        @AuraEnabled public Integer qty{set;get;}
        @AuraEnabled public String lastId{set;get;}
        public Pageable(){}

        /**
         * @param Integer qty -quantity of registries for excution
         * @param String lastId - last id from last retrieve regitries
         */
        public Pageable(Integer qty, String lastId){
            this.qty= qty;
            this.lastId= lastId;

        }

    }

  /**
    * @description retrieve ProcessInstance
    * @param Pageable
    * @param User Id
    * @param Name Object
    * @return List<ProcessInstance>
    */
    virtual public List<ProcessInstance> getStartedProcessByUserAndObjectNameAndNotInStatusPageable(Pageable page, Id userId, String objectName, List<string> status){
        List<ProcessInstance> toReturn=[SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
        (SELECT ID FROM WorkItems WHERE ActorId = :userId),
        (SELECT OriginalActor.Name,Comments FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance where
            TargetObjectId > :page.lastId and TargetObject.Type= :objectName and status not in :status and Id in (Select ProcessInstanceId from ProcessInstanceWorkitem where ActorId = :userId)
        ORDER BY TargetObjectId ASC, CreatedDate DESC LIMIT :page.qty];

        return filterFields(toReturn);
    }

  /**
    * @description retrieve ProcessInstance
    * @param Pageable
    * @param User Id
    * @return List<ProcessInstance>
    */
    virtual public List<ProcessInstance> getStartedProcessByUserIdAndNotInStatusPageable(Pageable page, Id userId, List<string> status){
        List<ProcessInstance> toReturn= [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                                 (SELECT ID FROM WorkItems WHERE ActorId = :userId),
                                 (SELECT OriginalActor.Name,Comments FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance where
                                    TargetObjectId > :page.lastId and status not in :status and Id in (Select ProcessInstanceId from ProcessInstanceWorkitem where ActorId = :userId)
                                 ORDER BY TargetObjectId ASC, CreatedDate DESC LIMIT :page.qty];

        return filterFields(toReturn);
    }

    /**
    * @description count ProcessInstance for user logged and object name
    * @param User Id
    * @param Status
    * @param Object Name
    * @return Integer
    */
    public Integer countPendingApproval(Id userId, List<String> status, String objectName){
        if(String.isNotEmpty(objectName)){
            if (!Schema.sObjectType.ProcessInstanceWorkitem.fields.OriginalActorId.isAccessible()) {
                return 0;
            }
            return (Integer) [Select count(Id) cReg from ProcessInstanceWorkitem where ProcessInstance.status not in :status and ProcessInstance.TargetObject.Type = :objectName and ActorId = :userId].get(0).get('cReg');
        }
        return (Integer) [Select count(Id) cReg from ProcessInstanceWorkitem where ProcessInstance.Status not in :status and ActorId = :userId WITH SECURITY_ENFORCED].get(0).get('cReg');
    }

    /**
    * @description
    * @author Cleberson Barbosa | 05-11-2022
    * @param String developerName
    * @return List<MassApprovalProcessAttribute__mdt>
    **/
    virtual public List<MassApprovalProcessAttribute__mdt> getMetadata(String developerName){
        return filterFields([Select MasterLabel,Country__c,Parent_Object_API_Name__c,Parent_Object_Fields_API_Name__c,Child_Object_Fields_API_Name__c from MassApprovalProcessAttribute__mdt Where developerName = :developerName WITH SECURITY_ENFORCED LIMIT 1]);
    }
    public List<ProcessInstanceWorkitem> getInstanceWorkByUserAndStatus(Id userId, String status){
        return [Select ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ActorId = :userId and ProcessInstance.status = :status WITH SECURITY_ENFORCED];
    }

    /**
    * @description Filter objects has no access
    * @param List<ProcessInstance>
    * @return List<ProcessInstance>
    */
    private List<SObject> filterFields(List<SObject> instances){
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, instances, true);

        return decision.getRecords();
    }

}