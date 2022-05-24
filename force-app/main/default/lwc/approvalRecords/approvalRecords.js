import { refreshApex } from '@salesforce/apex';
import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import {registerListener, unregisterListener} from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import titleApproval from '@salesforce/label/c.PendingApproval';
import noData from '@salesforce/label/c.MassApprovals_No_Data_Message';
import noDataHelp from '@salesforce/label/c.MassApprovals_No_Data_HelpText';
import selectOneOption from '@salesforce/label/c.giic_selectCutsOrSubsOption';
import nothingSelection from '@salesforce/label/c.SP4CopySPPriceNothingSelected';
import submitterComments from '@salesforce/label/c.MassApprovals_Submitter_Comments';
import approveLabel from '@salesforce/label/c.MassApprovals_Approve';
import rejectLabel from '@salesforce/label/c.MassApprovals_Reject';
import refreshLabel from '@salesforce/label/c.SP4RURefreshButton';
import getWrapperClassList from '@salesforce/apex/MultiRecordsApprovalController.filter';
import gettotalcount from '@salesforce/apex/MultiRecordsApprovalController.gettotalcount';
import processRecords from '@salesforce/apex/MultiRecordsApprovalController.processRecords';
import processAllRecords from '@salesforce/apex/MultiRecordsApprovalController.proccessAllrecords';
import approveAllRecordsWithQuantity from '@salesforce/label/c.ApproveAllRecordsWithQuantity'

if (!String.prototype.format) {
    String.prototype.format = function() {
      var args = arguments;
      return this.replace(/{(\d+)}/g, function(match, number) {
        return typeof args[number] != 'undefined'
          ? args[number]
          : match
        ;
      });
    };
  }

export default class ApprovalRecords extends LightningElement {
    label = {
        noData,
        noDataHelp,
        selectOneOption,
        submitterComments,
        approveLabel,
        rejectLabel,
        refreshLabel,
        approveAllRecordsWithQuantity
    };

    @api wrapperList = [];
    @api draftValues = [];
    @track sortBy;
    @track sortDirection;
    @track bShowModal = false;
    @track selectedcommentrowno;
    @track icomments = '';
    @track record;
    @track totalRecordCount;
    @track showinfiniteLoadingSpinner = true;
    @track showLoadingSpinner = false;
    @track isDialogVisible = false;
    @track originalMessage;
    @track title = titleApproval;

    @track enable_app_rej = true;
    @api objectname='';
    @api columns;
    @api columnsnames='';
    filters={};
    @track eventApproval;

    @track pagesize=10;

    @wire(CurrentPageReference) pageRef;

    @track pageable={qty:this.pagesize, lastId:''};

    renderedCallback(){

        registerListener(
            'filterregistries',
            this.handleFilters,
            this
        );
    }

    disconnectedCallback() {
        unregisterListener('filterregistries', this.handleFilters, this);
    }

    handleFilters = (event) => {
        this.filters = event.detail;
        this.reloadrecords();
    }

    wiredcountResults;
    @wire(gettotalcount,{objectName:'$objectname'})
    totalcount(result) {
        this.wiredcountResults = result;
        this.totalRecordCount= 0;
        if (result.data !=undefined) {
            this.totalRecordCount = result.data;
            this.loadRecords();
        }
        this.title= titleApproval.format(`(${this.totalRecordCount})`);
        this.dispatchEvent(new CustomEvent('changetitle',{detail: this.title}));
    }

    reloadrecords() {
        this.showinfiniteLoadingSpinner = true;
        this.showLoadingSpinner = true;

        this.pageable={qty:this.pagesize, lastId:''};
        this.wrapperList = [];
        this.loadRecords();
    }

    loadRecords() {
        getWrapperClassList({ page: this.pageable, inputParams: this.filters, objectName: this.objectname, columnsNames: this.columnsnames })
            .then(result => {
                if (result && result.length>0) {
                    result= this.flatternObjects(result);
                    this.wrapperList = [...this.wrapperList, ...result];
                    this.showinfiniteLoadingSpinner = true;
                }
                this.showLoadingSpinner=false;
                return refreshApex(this.wiredcountResults);
            }).catch(error => {
                this.showinfiniteLoadingSpinner = false;
                this.error = error;
                this.showToast('Error', error.body?.message, 'info');
                return refreshApex(this.wiredcountResults);

            });
    }

    loadMoreData(event) {
        if (this.totalRecordCount <= this.wrapperList.length) {
            this.showinfiniteLoadingSpinner = false;
            return refreshApex(this.wiredcountResults);
        }else if(this.showinfiniteLoadingSpinner){
            let { target } = event;
            target.isLoading = true;
            this.loadRecords();
            target.isLoading = false;
        }
        this.showinfiniteLoadingSpinner = false;
    }

    handleSave(event) {
        let draftlst = [];
        this.showLoadingSpinner=true;
        draftlst = event.detail.draftValues;
        this.wrapperList.forEach(element => {
            let work=draftlst.find(el=> element.workItemId == el.workItemId);
            if(work){
                element.comments = work.comments;
            }
        });

        this.draftValues = [];
        this.showLoadingSpinner=false;
        this.showToast('Success', 'Approver comments Added.', 'success');
    }
    enablebuttons(event){
         let selectedRows = event.detail.selectedRows;
         let recordsCount = event.detail.selectedRows.length;
         if(recordsCount > 0){
            this.enable_app_rej = false;
         }else{
            this.enable_app_rej = true;
         }
    }
    processrec() {
        let el = this.template.querySelector('lightning-datatable');
        let selectedrows = el.getSelectedRows();
        let varprocessType = this.eventApproval;// event.target.label;
        let processrows = [];
        this.showLoadingSpinner=true;
        for (let i = 0; i < selectedrows.length; i++) {
            processrows.push(selectedrows[i]);
        }
        if (processrows.length > 0) {
            processRecords({ processType: varprocessType, strwraprecs: processrows })
                .then(result => {
                    this.showinfiniteLoadingSpinner = true;
                    this.pageable={qty:this.pagesize, lastId:''};
                    this.wrapperList = [];
                    this.showToast(result, '', 'success');
                    return this.loadRecords();
                }).catch(error => {
                    this.showToast('Error', error.body?.message, 'info');
                    return refreshApex(this.wiredcountResults);
                });
        }else {
            this.showToast(nothingSelection,  selectOneOption, 'warning');
        }
    }

    proccessAll(){
        let varprocessType = this.eventApproval;

        processAllRecords({objectName: this.objectname, processType: varprocessType}).then(result =>{
            this.showinfiniteLoadingSpinner = true;
            this.pageable={qty:this.pagesize, lastId:''};
            this.wrapperList = [];
            this.showToast(result, '', 'success');
            return this.loadRecords();

        }).catch(error => {
            this.showToast('Error', error.body?.message, 'info');
            return refreshApex(this.wiredcountResults);
        });
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
        let actionName = event.detail.action.name;
        let row = event.detail.row;
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
        let { workItemId } = row;
        this.record = row;
        this.icomments = this.record.submitterComments;
    }
    viewrecord(row) {
        this.record = row;
        window.open(this.record.recordId, '_blank');

    }
    handleconformClick(event) {
        try {
            if (event.target && event.target.label && (event.target.label.includes(approveLabel) || event.target.label.includes(rejectLabel))) {
                this.eventApproval = event.target.label;
                if(this.eventApproval.includes('All')){
                    this.originalMessage= approveAllRecordsWithQuantity.format(event.target.label, this.totalRecordCount);
                }else{
                    let el = this.template.querySelector('lightning-datatable');
                    let selectedrows = el.getSelectedRows();
                    this.originalMessage= approveAllRecordsWithQuantity.format(event.target.label, selectedrows.length);

                }
                this.isDialogVisible = true;
            }
            else if (event.target.name === 'confirmModal') {
                //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
                if (event.detail !== 1) {
                    if (event.detail.status === 'confirm') {
                        if(this.eventApproval.includes('All')){
                            this.proccessAll();
                        }else{
                            this.processrec();
                        }

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
    showToast(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    flatternObjects(values){
        let result=[];
        values.forEach(element => {
            element.recordId = '/' + element.recordId;
            result=[...result, this.flattenJSON(element)]
            this.pageable.lastId = result.reduce(function(prev, current) {
                return (prev.Id > current.Id) ? prev : current}).Id;

        });
        return result;
    }

    flattenJSON(obj = {}, res = {}, extraKey = ''){
        for(let key in obj){
           if(typeof obj[key] !== 'object'){
            res[extraKey + key] = obj[key];
           }else{
               let k= key=='obj' ? `${extraKey}`: `${extraKey}${key}.`;
              this.flattenJSON(obj[key], res, k);
           };
        };
        return res;
     };

    @api handleChangePageSize(event){
        this.pagesize = event.detail.value;
        this.showLoadingSpinner = true;
        this.wrapperList=[];
        this.loadRecords();
    }
}