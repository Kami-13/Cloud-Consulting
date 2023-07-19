import { LightningElement, track, api } from 'lwc';

export default class DatePicker extends LightningElement {

    @api min;
    @api max;
    @track fromDate = '';
    @track toDate = '';

    //handle date changes in the pickers and send the events to the parent component
    handleFromDateChange(event){

        this.fromDate = event.target.value;

        console.log(this.fromDate);

        const sendstartdate = new CustomEvent('sendstartdate', {
            
            detail:{

                selectedStartDate: this.fromDate
            }
        });
        this.dispatchEvent(sendstartdate);

    }

    handleToDateChange(event){

        this.toDate = event.target.value;

        console.log(this.toDate);

        const sendenddate = new CustomEvent('sendenddate', {
            
            detail:{
    
                selectedEndDate: this.toDate
            }
        });
        
        this.dispatchEvent(sendenddate);

    }

}