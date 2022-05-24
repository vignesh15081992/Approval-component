# Mass Approval Widget
[![Generic badge](https://img.shields.io/badge/Build-Passed-green.svg)]()  [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)]() [![Generic badge](https://img.shields.io/badge/Code%20coverage-95%25-green.svg)]()

## App Details

Salesforce in default doesn't have a screen to approve or reject the pending approval items in one go. Users need to click/ open each item and do the approvals. This screen enables user to select the records and do the approvals by clicking Approve or Reject button. This component is developed on LWC framework which is faster and lightweight in salesforce platform. Since this is a generic screen, so we can place anywhere.


|  |  |
| ------ | ------ |
| **Platform** | Salesforce Lightning Platform |
| **Framework** | LWC (Lightning Web Components) |
| **Package Version Name** | Initial Release |
| **Package Version Number** | 1.0 (Released) |
### Available for
  Lightning Home Page, Lightning App page, Lightning App utility Bar (1000 x 400) pixels in Lightning App.

## Features
 - Mass Approve/ Reject Approval requests
 - View Records and View Submitter Comments
 - Infinite scrolling of records with seamless lazy loading
 - Mass enter Approver comments and comment and fill the same on chosen records
 - You can sort Item Name, related to, Submitter, Submitted date
 - Wrap Text/ Clip Text options on Columns
 - Refresh button to refresh the Approval requests.
 - Approve/ Reject All records for logged user

## Screenshot
**Screen with approvals**

![image](https://drive.google.com/uc?export=view&id=1D7uKfAhfpwN7rLla85SKo62BCiuRBSod)

## Deployment 
You can deploy this widget as managed Package in your Salesforce instance.
```sh
URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0K000001VKBF
```
- Choose `All users` while deploying the package.
> ***Before you install***, 
Create a approval process in contact object named as `Test_Approval` with entry criteria as `LastName` is not blank and activate. This is used for installing package. After installation completes, delete this approval process. we are doing this because approval process is not available for packaging.

## Todos

 - [ ] Optimize code
 - [ ] Add undo function for Approve and Reject actions.
 - [ ] Add Night Mode

### Reference :+1:
  - [SFDCMonkey](https://sfdcmonkey.com/2020/04/11/approval-screen-sfdc-lightning/) - provides the basic approach on mass approval using AURA and apex which is simple and I just made it in LWC with more options.  
  - [Vignesh Mohankumar](https://github.com/vignesh15081992/Approval-component) - provides the custom component for approval/reject in LWC



