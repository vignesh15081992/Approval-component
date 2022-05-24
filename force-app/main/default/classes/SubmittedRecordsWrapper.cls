/**
 * @author       Cleberson Barbosa das Chagas
 * @Description:  Wrapper class for populate table
 * @Date:         11.04.2022
 *
 **/
public with sharing class SubmittedRecordsWrapper{
    @AuraEnabled public Id workItemId{get; set;}
    @AuraEnabled public String recordId{get; set;}
    @AuraEnabled public String relatedTo{get; set;}
    @AuraEnabled public String submittedBy{get; set;}
    @AuraEnabled public Date submittedDate{get; set;}
    @AuraEnabled public String submitterComments{get; set;}
    @AuraEnabled public String recordName{get; set;}
    @AuraEnabled public sObject obj {get; set;}
    @AuraEnabled public String comments{get; set;}


    public SubmittedRecordsWrapper(){
        this.submitterComments='';
        comments='';
    }

    public SubmittedRecordsWrapper(Id workItemId, String recordId, String recordName, String relatedTo, Date submittedDate) {
        this(workItemId, recordId, recordName, relatedTo, submittedDate, null);
    }

    public SubmittedRecordsWrapper(Id workItemId, String recordId, String recordName, String relatedTo, Date submittedDate, SObject objectClass) {
        this();
        this.workItemId = workItemId;
        this.recordId = recordId;
        this.relatedTo = relatedTo;
        this.recordName = recordName;
        this.submittedDate = submittedDate;
        this.obj=objectClass;
    }
}