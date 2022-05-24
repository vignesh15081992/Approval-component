/**
 * @description       : 
 * @author            : Cleberson Barbosa
 * @group             : 
 * @last modified on  : 05-18-2022
 * @last modified by  : Cleberson Barbosa
**/
@IsTest
public class ProcessInstanceRepositoryTest {
    private static List<String> status = new List<String>{Label.Approval_Status_Approved, Label.Approval_Status_Rejected};

    @IsTest
    static void makeData(){
        ProcessInstanceRepository processInstanceRepository= new ProcessInstanceRepository();
        ProcessInstanceRepository.Pageable page= new ProcessInstanceRepository.Pageable(0,'');

        System.assertEquals(0, processInstanceRepository.getStartedProcessByUserAndObjectNameAndNotInStatusPageable(page, UserInfo.getUserId(), 'Campaign', status).size(), '');
        System.assertEquals(0, processInstanceRepository.getStartedProcessByUserIdAndNotInStatusPageable(page, UserInfo.getUserId(), status).size(), '');
        System.assertEquals(0, processInstanceRepository.countPendingApproval(UserInfo.getUserId(), status,''), '');
    }

    public class ProcessInstanceRepositoryMock extends ProcessInstanceRepository{
        override public List<MassApprovalProcessAttribute__mdt> getMetadata(String name){
            MassApprovalProcessAttribute__mdt metadata=new MassApprovalProcessAttribute__mdt();
            metadata.Parent_Object_Fields_API_Name__c='Id,Name';
            metadata.Parent_Object_API_Name__c='gii__SalesOrder__c';
            metadata.Child_Object_Fields_API_Name__c='Id,Name';

            return new List<MassApprovalProcessAttribute__mdt>{metadata};

        }
    }
}
