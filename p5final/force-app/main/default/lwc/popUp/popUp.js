import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import ToastLine from '@salesforce/resourceUrl/ToastLine';

export default class PopUp extends LightningElement {

    @api user;
    @api dates;
    popUpBody;
    popUpDates;

    @track isModalOpen = false;

    openModal() {

        this.isModalOpen = true;

        //when modal opens, get the user's dates that come from parent component
        const index = Object.keys(this.dates).indexOf(`${this.user}`);

        //create an array with the dates
        const filteredDates = Object.values(this.dates)[index];

            //check array's length to determine if the user is free during project dates
            if(filteredDates.length == 0){

                console.log('if');
    
                this.popUpBody = 'The Resource is free over the duration of this project.'
            }
            else{

                console.log('else');

                this.popUpBody = `The resource can't be allocated on the following dates:\n`
                this.popUpDates = ''

                //loop through the dates to create the modal's body
                for(let item of filteredDates){

                    this.popUpDates += `[${item.Date_Start__c} - ${item.Date_End__c}]\n`

                }
                    
            }
        
    }

    closeModal(){

        this.isModalOpen = false;
    }

    //style loading for the break lines in the modal's body
    renderedCallback() {

        loadStyle(this, ToastLine)
        .then(() => console.log('Files loaded.'))
        .catch(error => console.log("Error " + error.body.message))

    }
}