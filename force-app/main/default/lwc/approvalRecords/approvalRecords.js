import { LightningElement, track, api, wire } from 'lwc';
import getWrapperClassList from '@salesforce/apex/MultiRecordsApprovalController.getSubmittedRecords';
import processRecords from '@salesforce/apex/MultiRecordsApprovalController.processRecords';
import gettotalcount from '@salesforce/apex/MultiRecordsApprovalController.gettotalcount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
export default class ApprovalRecords extends LightningElement {
    @api wrapperList = [];
    @api draftValues = [];
    @track error;
    @track sortBy;
    @track sortDirection;
    @track bShowModal = false;
    @track selectedcommentrowno;
    @track icomments = '';
    @track record;
    @track queryOffset;
    @track queryLimit;
    @track totalRecordCount;
    @track showinfiniteLoadingSpinner = true;
    @track showLoadingSpinner = false;
    @track isDialogVisible = false;
    @track originalMessage;
    @track wrapperListtrue = true;
    @track title;
    @api footertext;
    @track enable_app_rej = true;
    @track columns = [

        /* {
             label: '#',
             fieldName: 'recordId',
             type: 'url',
             initialWidth:50,
             typeAttributes: { label: 'View', target: '_blank' }
         },*/

        {
            type: 'button-icon',
            fixedWidth: 40,
            typeAttributes: {
                iconName: 'utility:preview',
                name: 'view_record',
                title: 'View Record',
                variant: 'border-filled',
                alternativeText: 'View Record',
                disabled: false
            }
        },
        {
            type: 'button-icon',
            fixedWidth: 40,
            typeAttributes: {
                iconName: 'utility:comments',
                name: 'submitter_comments',
                title: 'Submitter comments',
                variant: 'border-filled',
                alternativeText: 'Submitter comments',
                disabled: false
            }
        },
        {
            label: 'Item Name',
            fieldName: 'recordName',
            type: 'text',
            initialWidth: 200,
            wrapText: true,
            sortable: true
        },
        {
            label: 'Related to',
            fieldName: 'relatedTo',
            type: 'text',
            initialWidth: 100,
            sortable: true
        },
        {
            label: 'Submitter',
            fieldName: 'submittedBy',
            type: 'text',
            initialWidth: 120,
            sortable: true
        },
        {
            label: 'Submitted on',
            fieldName: 'submittedDate',
            type: 'date',
            initialWidth: 120,
            typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric'
                //hour: '2-digit',
                //minute: '2-digit',
                //second: '2-digit',
                //hour12: true
            },
            sortable: true
        },

        {
            label: 'Approver Comment',
            fieldName: 'comments',
            type: 'text',
            initialWidth: 290,
            wrapText: true,
            editable: true
        }
    ];
    wiredcountResults;
    @wire(gettotalcount) totalcount(result) {
        console.log('result.data' + result.data);
        this.wiredcountResults = result;
        if (result.data != undefined) {
            this.totalRecordCount = result.data;
            console.log('tota' + this.totalRecordCount);
            this.title = 'Your Pending Approvals (' + this.totalRecordCount + ')';
            if (result.data > 0)
                this.wrapperListtrue = true;
            else {
                this.totalRecordCount = 0;
                this.title = 'Your Pending Approvals';
                this.wrapperListtrue = false;
                console.log('tota' + this.totalRecordCount);
            }
        } else if (result.error) {
            this.error = result.error;
            this.totalRecordCount = 0;
            this.title = 'Your Pending Approvals (' + this.totalRecordCount + ')';
            this.wrapperListtrue = false;
            console.log('tota' + this.totalRecordCount);
        }
    }
    constructor() {
        super();
        this.title = 'Your Pending Approvals';
        this.showinfiniteLoadingSpinner = true;
        this.wrapperList = [];
        this.queryOffset = 0;
        this.queryLimit = 5;
        this.loadRecords();
    }
    reloadrecords() {
        this.showLoadingSpinner = true;
        this.showinfiniteLoadingSpinner = true;
        this.queryOffset = 0;
        this.queryLimit = 5;
        let flatData;
        this.wrapperList = [];
        console.log(this.totalRecordCount);
        return getWrapperClassList({ queryLimit: this.queryLimit, queryOffset: this.queryOffset })
            .then(result => {
                console.log(result);
                console.log(this.totalRecordCount);
                flatData = result;
                if (flatData != undefined) {
                    for (var i = 0; i < flatData.length; i++) {
                        flatData[i].recordId = '/' + flatData[i].recordId;
                    }
                    this.wrapperList = flatData;
                }
                this.showLoadingSpinner = false;
                console.log(this.wrapperList);
                this.showLoadingSpinner = false;
                return refreshApex(this.wiredcountResults);
                //this.error = undefined;
            }).catch(error => {
                console.log(error);
                this.showLoadingSpinner = false;
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'info'
                    })
                );
                return refreshApex(this.wiredcountResults);
            })
    }
    loadRecords() { //you can build a method for a button
        console.log('tetst');
        this.showLoadingSpinner = true;

        let flatData;

        console.log('lr' + this.queryOffset);
        console.log('lr' + this.queryLimit);
        return getWrapperClassList({ queryLimit: this.queryLimit, queryOffset: this.queryOffset })
            .then(result => {
                console.log(result);
                flatData = result;
                if (flatData != undefined) {
                    for (var i = 0; i < flatData.length; i++) {
                        flatData[i].recordId = '/' + flatData[i].recordId;
                    }

                    let updatedRecords = [...this.wrapperList, ...flatData];
                    this.wrapperList = updatedRecords;
                }
                this.showLoadingSpinner = false;
                console.log(this.wrapperList);
                refreshApex(this.wiredcountResults);
                this.title = 'Your Pending Approvals (' + this.totalRecordCount + ')';
            }).catch(error => {
                console.log(error);
                this.showLoadingSpinner = false;
                this.error = error;
                refreshApex(this.wiredcountResults);
                this.title = 'Your Pending Approvals (' + this.totalRecordCount + ')';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'info'
                    })
                );
            })
    }
    loadMoreData(event) {
        const { target } = event;
        this.showinfiniteLoadingSpinner = true;
        //Display a spinner to signal that data is being loaded
        console.log('lmr totalRecordCount' + this.totalRecordCount);
        console.log('lmr queryLimit' + this.queryLimit);
        console.log('lmr queryOffset' + this.queryOffset);
        if (this.totalRecordCount < this.queryLimit) {
            console.log(this.wrapperList);
            this.showinfiniteLoadingSpinner = false;
            return refreshApex(this.wiredcountResults);
        }
        else if (this.totalRecordCount > this.queryOffset) {
            this.queryOffset = this.queryOffset + 5;
            console.log('lmir queryLimit' + this.queryLimit);
            console.log('lmir queryOffset' + this.queryOffset);
            let flatData;
            return getWrapperClassList({ queryLimit: this.queryLimit, queryOffset: this.queryOffset })
                .then(result => {
                    target.isLoading = false;
                    console.log(result);
                    console.log(this.totalRecordCount);
                    flatData = result;
                    if (flatData != undefined) {
                        for (var i = 0; i < flatData.length; i++) {
                            flatData[i].recordId = '/' + flatData[i].recordId;
                        }
                        //this.wrapperList = this.wrapperList.concat(flatData);
                        let updatedRecords = [...this.wrapperList, ...flatData];
                        this.wrapperList = updatedRecords;
                    }
                    target.isLoading = false;
                    console.log(this.wrapperList);
                    this.showinfiniteLoadingSpinner = false;
                    return refreshApex(this.wiredcountResults);
                }).catch(error => {
                    console.log(error);
                    this.showinfiniteLoadingSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'info'
                        })
                    );
                    return refreshApex(this.wiredcountResults);
                })
        } else {
            this.showinfiniteLoadingSpinner = false;
            target.isLoading = false;
            return refreshApex(this.wiredcountResults);
        }

    }

    handleSave(event) {
        this.showLoadingSpinner = true;
        console.log(event.detail.draftValues);
        console.log(this.wrapperList);
        var draftlst = [];
        draftlst = event.detail.draftValues;
        for (var i = 0; i < this.wrapperList.length; i++) {
            console.log(this.wrapperList[i].workItemId);
            for (var j = 0; j < draftlst.length; j++) {
                console.log(draftlst[j].workItemId);
                if (this.wrapperList[i].workItemId === draftlst[j].workItemId) {
                    this.wrapperList[i].comments = draftlst[j].comments;
                }
            }
        }
        for (var i = 0; i < this.wrapperList.length; i++) {
            console.log(this.wrapperList[i].comments);
        }
        this.draftValues = [];
        this.showLoadingSpinner = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Approver comments Added.',
                variant: 'success'
            })
        );
    }
    enablebuttons(event)
    {
         const selectedRows = event.detail.selectedRows;
         var recordsCount = event.detail.selectedRows.length;
         if(recordsCount > 0)
         this.enable_app_rej = false;
         else
         this.enable_app_rej = true;
         
    }
    processrec() {
        this.showLoadingSpinner = true;
        console.log('test');
        var el = this.template.querySelector('lightning-datatable');
        var selectedrows = el.getSelectedRows();
        console.log(selectedrows);
        // console.log(event.target.label);
        var varprocessType = this.originalMessage;// event.target.label;
        var processrows = [];
        for (var i = 0; i < selectedrows.length; i++) {
            processrows.push(selectedrows[i]);
        }
        if (processrows.length > 0) {
            var str = JSON.stringify(processrows);
            processRecords({ processType: varprocessType, strwraprecs: str })
                .then(result => {
                    this.showinfiniteLoadingSpinner = true;
                    this.queryOffset = 0;
                    this.queryLimit = 5;
                    let flatData;
                    this.wrapperList = [];
                    console.log(this.totalRecordCount);
                    return getWrapperClassList({ queryLimit: this.queryLimit, queryOffset: this.queryOffset })
                        .then(result => {
                            console.log(result);
                            console.log(this.totalRecordCount);
                            flatData = result;
                            if (flatData != undefined) {
                                for (var i = 0; i < flatData.length; i++) {
                                    flatData[i].recordId = '/' + flatData[i].recordId;
                                }
                                this.wrapperList = flatData;
                            }
                            this.showLoadingSpinner = false;
                            console.log(this.wrapperList);
                            this.showLoadingSpinner = false;
                            var messagetitle;
                            var ivariant;
                            if(varprocessType == 'Approve')
                            {
                                messagetitle = 'Selected records are Approved.';
                                ivariant = 'success';
                            }
                            else if(varprocessType == 'Reject')
                            {
                                messagetitle = 'Selected records are Rejected.';
                                ivariant = 'error';
                            }
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: messagetitle,
                                    message: result,
                                    variant: ivariant
                                })
                            );
                            return refreshApex(this.wiredcountResults);
                        }).catch(error => {
                            console.log(error);
                            this.showLoadingSpinner = false;
                            this.error = error;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: result,
                                    variant: 'info'
                                })
                            );
                            return refreshApex(this.wiredcountResults);
                        })
                })
                .catch(error => {
                    this.showLoadingSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'error'
                        })
                    );
                    return refreshApex(this.wiredcountResults);
                });
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No Records chosen.',
                    message: 'Please select records to proceed.',
                    variant: 'warning'
                })
            );
            this.showLoadingSpinner = false;
        }
    }

    handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
    sortData(fieldname, direction) {
        this.showLoadingSpinner = true;
        let parseData = JSON.parse(JSON.stringify(this.wrapperList));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            return isReverse * ((x > y) - (y > x));
        });
        this.wrapperList = parseData;
        this.showLoadingSpinner = false;
    }
    openModal() { this.bShowModal = true; }
    closeModal() { this.bShowModal = false; }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        var row = event.detail.row;
        console.log(row);
        switch (actionName) {
            case 'view_record':
                this.viewrecord(row);
                break;
            case 'submitter_comments':
                this.opencomment(row);
                break;
            default:
        }
    }
    opencomment(row) {
        this.bShowModal = true;
        console.log(row);
        const { workItemId } = row;
        console.log(workItemId);
        this.record = row;
        console.log(this.record);
        this.icomments = this.record.submittercomment;
        console.log(this.bShowModal);
    }
    viewrecord(row) {
        this.record = row;
        console.log(this.record.recordId);
        window.open(this.record.recordId, '_blank');

    }
    handleconformClick(event) {
        try {
        if (event.target.label === 'Approve') {
            console.log('label' + event.target.label);
            this.originalMessage = event.target.label;
            this.isDialogVisible = true;
        }
        else if (event.target.label === 'Reject') {
            console.log('label' + event.target.label);
            this.originalMessage = event.target.label;
            this.isDialogVisible = true;
        }
        else if (event.target.name === 'confirmModal') {
            console.log(event.detail);
            //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
            if (event.detail !== 1) {
                console.log('status' + event.detail.status); 
                if (event.detail.status === 'confirm') {
                    this.processrec();
                    this.isDialogVisible = false;
                } else if (event.detail.status === 'cancel') {
                    //do something else
                    this.isDialogVisible = false;
                }
            }
            
        }
        }
        catch(e) {
            console.log(e);
        }
    }
}