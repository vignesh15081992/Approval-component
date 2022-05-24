@isTest
public class MultiRecordsApprovalControllerTest {
    public static testMethod void method1(){
        // Insert an account
        Contact c = new Contact(FirstName='Test',LastName='ttest',Email='test@test.com');
        insert c;

        User user1 = [SELECT Id FROM User WHERE Profile.Name='System administrator' limit 1];

        Approval.ProcessSubmitRequest req =     new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval via form');
        req.setObjectId(c.Id);
     
        //Step 3:  Submit on behalf of a specific submitter
        req.setSubmitterId(UserInfo.getUserId()); 
   
        //Step 4:  Submit the record to specific process and skip the criteria evaluation
        req.setProcessDefinitionNameOrId('Test_Approval');
        req.setSkipEntryCriteria(true);

        //Step 5:  Submit the approval request for the bid
        Approval.ProcessResult result = Approval.process(req);

        System.assertEquals('Pending', result.getInstanceStatus(),'Instance Status '+result.getInstanceStatus());

        Test.startTest();
        ProcessInstanceRepositoryTest.ProcessInstanceRepositoryMock rep=new ProcessInstanceRepositoryTest.ProcessInstanceRepositoryMock();

        MassApprovalProcessAttribute__mdt metadata=rep.getMetadata('').get(0);

        System.assertEquals(1,MultiRecordsApprovalController.gettotalcount(''), 'Have one approval record');
        List<SubmittedRecordsWrapper> prorec = MultiRecordsApprovalController.filter(new ProcessInstanceRepository.Pageable(1,''), null, '', '');
        prorec = MultiRecordsApprovalController.filter(new ProcessInstanceRepository.Pageable(1,''), null, metadata.Parent_Object_API_Name__c, metadata.Parent_Object_Fields_API_Name__c);

        FilterRegistries filter =FilterRegistries.getInstance('BrPgdCampaign');
        filter.setRepo(rep);

        filter.getConfiguration('BrPgdCampaign');
        filter.populateFilters(metadata);

        string resultrec = MultiRecordsApprovalController.processRecords('Approve',prorec);
        System.assert(resultrec.contains('All records are Approved successfully'), 'All records are Approved successfully');
        System.assertEquals(0,MultiRecordsApprovalController.gettotalcount(''), 'Have one approval record');

        Test.stopTest();
    }
    
    @IsTest
    public static void test2(){
        String app='[{"attributes":{"type":"ProcessInstance","url":"/services/data/v51.0/sobjects/ProcessInstance/04g1o0000028y7hAAA"},"Id":"04g1o0000028y7hAAA","TargetObjectId":"0061o00000k0dWnAAI","TargetObject":{"attributes":{"type":"Name","url":"/services/data/v51.0/sobjects/Opportunity/0061o00000k0dWnAAI"},"Name":"2018 NTR NTASP CP--CP-Jiangsu-江苏金华农资连锁有限公司高邮永昌店（金华农资永昌店）"},"CreatedDate":"2018-03-21T11:06:01.000+0000","Workitems":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"ProcessInstanceWorkitem","url":"/services/data/v51.0/sobjects/ProcessInstanceWorkitem/04i1o0000033RwpAAE"},"Id":"04i1o0000033RwpAAE"}]},"Steps":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"ProcessInstanceStep","url":"/services/data/v51.0/sobjects/ProcessInstanceStep/04h1o000004JhJFAA0"},"OriginalActor":{"attributes":{"type":"Name","url":"/services/data/v51.0/sobjects/User/00524000006psnoAAA"},"Name":"Ming Ni"},"Comments":"Submitting Sales Plan for approval"}]}}]';
        List<ProcessInstance> instances= (List<ProcessInstance>) JSON.deserialize(app, List<ProcessInstance>.class);
        MultiApprovalService multiApprovalService= new MultiApprovalService();
        List<SubmittedRecordsWrapper> wrappers= multiApprovalService.builderWrapper(instances).values();
        System.assertEquals(1, wrappers.size(), '');

        MultiRecordsApprovalController.processRecords('Approve',wrappers);
    }

    @IsTest
    public static void testGetColumns(){
        FilterRegistries instance= MultiRecordsApprovalController.getColumnsAndFilters('BrPgdCampaign');
        System.assertNotEquals(null, instance.columns, 'Has columns');
        System.assertNotEquals(null, instance.filters, 'Has filters');

    }

}
