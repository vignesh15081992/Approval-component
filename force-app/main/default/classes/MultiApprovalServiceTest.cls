/**
 * @description       :
 * @author            : Cleberson Barbosa
 * @group             :
 * @last modified on  : 05-12-2022
 * @last modified by  : Cleberson Barbosa
**/
@IsTest
public with sharing class MultiApprovalServiceTest {
    @IsTest
    public static void testGetObjectName(){
        MultiApprovalService multiApprovalService= new MultiApprovalService();
        System.assertEquals('Case', multiApprovalService.getObjectName(IDGenerator.generate(Case.getSObjectType())), '');
    }

    @IsTest
    public static void testBuilderWrapper(){
        String app='[{"attributes":{"type":"ProcessInstance","url":"/services/data/v51.0/sobjects/ProcessInstance/04g1o0000028y7hAAA"},"Id":"04g1o0000028y7hAAA","TargetObjectId":"0061o00000k0dWnAAI","TargetObject":{"attributes":{"type":"Name","url":"/services/data/v51.0/sobjects/Opportunity/0061o00000k0dWnAAI"},"Name":"2018 NTR NTASP CP--CP-Jiangsu-江苏金华农资连锁有限公司高邮永昌店（金华农资永昌店）"},"CreatedDate":"2018-03-21T11:06:01.000+0000","Workitems":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"ProcessInstanceWorkitem","url":"/services/data/v51.0/sobjects/ProcessInstanceWorkitem/04i1o0000033RwpAAE"},"Id":"04i1o0000033RwpAAE"}]},"Steps":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"ProcessInstanceStep","url":"/services/data/v51.0/sobjects/ProcessInstanceStep/04h1o000004JhJFAA0"},"OriginalActor":{"attributes":{"type":"Name","url":"/services/data/v51.0/sobjects/User/00524000006psnoAAA"},"Name":"Ming Ni"},"Comments":"Submitting Sales Plan for approval"}]}}]';
        List<ProcessInstance> instances= (List<ProcessInstance>) JSON.deserialize(app, List<ProcessInstance>.class);
        MultiApprovalService multiApprovalService= new MultiApprovalService();
        List<SubmittedRecordsWrapper> wrappers= multiApprovalService.builderWrapper(instances).values();
        System.assertEquals(1, wrappers.size(), '');

        System.assertEquals('2018 NTR NTASP CP--CP-Jiangsu-江苏金华农资连锁有限公司高邮永昌店（金华农资永昌店）', wrappers.get(0).recordName, '');
    }
    @IsTest
    public static void testMountSelect(){
        MultiApprovalService multiApprovalService= new MultiApprovalService();
        String sel= multiApprovalService.mountSelect(new Map<String, String>{}, new List<String>{'c1', 'c2'}, 'objectName');
        System.assertEquals('Select c1,c2 from objectName where Id in :ids ', sel, 'Selected returned based on filters and columns');
    }

    @IsTest
    public static void testMountSelectWhenHasFilter(){
        MultiApprovalService multiApprovalService= new MultiApprovalService();
        String sel= multiApprovalService.mountSelect(new Map<String, String>{'c1.Id'=>'1'}, new List<String>{'c1', 'c2'}, 'objectName');
        System.assertEquals('Select c1,c2 from objectName where Id in :ids  AND c1.Id= \'1\'', sel, 'Selected returned based on filters and columns');
    }
}
