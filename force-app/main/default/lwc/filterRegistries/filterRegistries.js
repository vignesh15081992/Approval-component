import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import clearFilter from '@salesforce/label/c.SYT_3R_CLEARFILTER_LABEL';

export default class FilterRegistries extends LightningElement {
    @api objectname;
    @track value={};
    @api options;
    @api show;
    @track disableBtn=true;
    label = {clearFilter}

    @wire(CurrentPageReference) pageRef;

    handleChange(event) {
        let id= event.target.id?.split('-')[0];
        this.value[id]=event.detail.value;
        //send event
        this.disableBtn=false;
        fireEvent(this.pageRef, 'filterregistries', {
            detail: this.value
        });
    }
    handleClearFilter(event){
        this.template.querySelectorAll('lightning-input[data-id="reset"]').forEach(element => {
            element.value = null;
        });
        this.disableBtn=true;
        this.value={};
        fireEvent(this.pageRef, 'filterregistries', {
            detail: this.value
        });
    }

}