import { LightningElement, track, api } from 'lwc';
import getColumnsAndFilters from '@salesforce/apex/MultiRecordsApprovalController.getColumnsAndFilters';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ApprovalRecordsFilter extends LightningElement {
    @api objectname;
    @api showfilter;
    @api metadataname;

    @track title;
    @track columns;
    @track filters;
    @track columnsNames;

    connectedCallback(){
        this.loadData();
    }

    loadData(){
        getColumnsAndFilters({metadataName: this.metadataname})
        .then(data=>{
            this.columns= data.columns;
            this.filters= data.filters;
            this.objectname= data.objectName;
            this.columnsNames= data.columnsNames.toString();
        }).catch(error=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: error.body?.message,
                    variant: 'error'
                })
            );
        });
    }

    get optionsPageSize() {
        return [
            { label: '10', value: '10' },
            { label: '20', value: '20' },
            { label: '30', value: '30' },
            { label: '40', value: '40' },
        ];
    }

    handleChangePageSize(event){
        this.template.querySelector('c-approval-records').handleChangePageSize(event);
    }

    handleTitle(event){
        this.title=event.detail;
    }
}