import { LightningElement, api, track, wire } from 'lwc';
import { MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE } from 'lightning/messageService';
import RMC from '@salesforce/messageChannel/ResourceMessageChannel__c';

export default class ResourceItem extends LightningElement {

    //wire message from message channel
    @wire(MessageContext)
    messageContext;
    subscription;

    @api user;
    @api userDates;
    @api relatedProject;
    @track checkTrue = true;

    minDate;
    maxDate;
    
    //format user to send object
    userToSend = ({
        Resource__c: '',
        Date_Start__c: null,
        Date_End__c: null,
        Project__c: '',
        Hours_Assigned_Resource__c: null
    });

    //handler for user's checkbox
    handleCheckboxChange(event){

        //when checked, change isCheckec variable and assign user's Id and related project
        const isChecked = event.target.checked;

        this.userToSend.Resource__c = this.user.Id;
        this.userToSend.Project__c = this.relatedProject.Id;

        //if checked, remove title attribute from pickers and load min and max dates
        if(isChecked){
            
            this.checkTrue = false;

            this.template.querySelectorAll('.picker').forEach(element => {
                element.removeAttribute('title');})

            this.minDate = new Date(this.relatedProject.Date_Start__c).toISOString().split('T')[0];
            this.maxDate = new Date(this.relatedProject.Date_End__c).toISOString().split('T')[0];
        
        //if unchecked, call deleteUser function, clear all fields and set back title attribute to pickers
        }else{

            this.checkTrue = true;

            this.deleteUser(this.user.Id);

            this.userToSend.userId = '';
            this.userToSend.startDate = null;
            this.userToSend.endDate = null;

            this.template.querySelectorAll('.clearClass').forEach(element => {
                element.value = '';})

            this.template.querySelectorAll('.clearClass').forEach(element => {
                element.setCustomValidity('');
                element.reportValidity();})

            this.template.querySelectorAll('.clearClass').forEach(element => {
                element.setAttribute('title', 'Please click the checkbox to enable this field');})
        }
    }

    //set start date and call hours handler function
    handleFrom(event){
        
        this.userToSend.Date_Start__c = event.target.value;

        this.handleHours(this.userToSend.Date_Start__c, this.userToSend.Date_End__c);

    }

    //set end date and call hours handler function
    handleTo(event){
        
        this.userToSend.Date_End__c = event.target.value;

        this.handleHours(this.userToSend.Date_Start__c, this.userToSend.Date_End__c);

        this.sendUser();

    }

    //calculate and assign hours based on amount of days selected
    //function multiplies each day times 8, and ignores sat and sun
    handleHours(startDateStr, endDateStr){

        const startDate = new Date(startDateStr);
        const endDate = new Date(endDateStr);

        console.log(startDate + endDate);
          
        let result = 0;

        let currentDate = new Date(startDate.getTime());
          
        while (currentDate <= endDate){

            currentDate.setDate(currentDate.getDate() + 1);

            const weekDay = currentDate.getDay();

            if(weekDay !== 0 && weekDay !== 6){

                result++;
            }
    
        }
          
        this.userToSend.Hours_Assigned_Resource__c = result*8;
    }

    //event to send user to grandparent component
    sendUser(){

        const event = new CustomEvent('usertosendchange', {
            detail: this.userToSend,
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(event);
    }

    //event to send user TO DELETE to grandparent component
    deleteUser(userId){

        const event = new CustomEvent('deleteuser', {
            detail: userId,
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(event);
    }

    //subscription to message channel
    connectedCallback() {

        this.subscription = subscribe(
            this.messageContext,
            RMC,
            (message) => {

                const messagePayload = message.payload;
                const clearInputs = messagePayload.clearInputs;

                if(clearInputs == true){

                    console.log('mensaje recibido');
                    this.clearFields();
                } 
            },
            { scope: APPLICATION_SCOPE }
        );
    }

    disconnectedCallback() {

        unsubscribe(this.subscription);
        this.subscription = null;
    }

    //function to clear all fields from each input element
    clearFields(){

        console.log('funcion');
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.type === 'checkbox') {
                element.checked = false;
                this.checkTrue = true;
            } else {
                element.value = '';
            }})
            
    }

}