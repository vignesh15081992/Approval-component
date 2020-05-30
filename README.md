# Mass Approval Widget
[![Generic badge](https://img.shields.io/badge/Build-Passed-green.svg)]()  [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)]() [![Generic badge](https://img.shields.io/badge/Code%20coverage-93%25-green.svg)]()

## App Details
|  |  |
| ------ | ------ |
| **Platform** | Salesforce Lightning Platform |
| **Framework** | LWC (Lightning Web Components) |
| **Version Name** | Beta Release |
| **Version Number** | 1.0 (BETA 5) |
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

## Screenshot
**Screen with approvals**
![image](https://drive.google.com/uc?export=view&id=1D7uKfAhfpwN7rLla85SKo62BCiuRBSod)

**Screen without approvals**
![image](https://drive.google.com/uc?export=view&id=198igrkNBA-WgFDthBORqJ_vWNKPUiXfU)

## Deployment 
You can deploy this widget as managed Package in your Salesforce instance.
```sh
URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0K000001VKBA
```
- Choose `All users` while deploying the package.
> ***Before you install***, 
Create a approval process in contact object named as `Test_Approval` with entry criteria as `LastName` is not blank and activate. This is used for installing package. After installation completes, delete this approval process.

## Todos

 - [ ] Optimize code
 - [ ] Add undo function for Approve and Reject actions.
 - [ ] Add Night Mode

### Follow @vignesh15081992,
- Trailblazer -  https://trailblazer.me/id/vigneshmohankumar
- Email - vigneshdj60@gmail.com
- Twitter Id - V_my_Atmosphere 


**Free Software, Hell Yeah!** :wink: :+1:



