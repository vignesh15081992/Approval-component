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

      

        Integer intvar = MultiRecordsApprovalController.gettotalcount();
        List<MultiRecordsApprovalController.SubmittedRecordsWrapper> prorec = new List<MultiRecordsApprovalController.SubmittedRecordsWrapper>();
        prorec = MultiRecordsApprovalController.getSubmittedRecords(5,0);
        string resultrec = MultiRecordsApprovalController.processRecords('Approve',Json.serialize(prorec));
    }
}