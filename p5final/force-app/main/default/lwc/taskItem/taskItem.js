import { LightningElement, api,track } from 'lwc';
import setTareasHoras from '@salesforce/apex/Controlador.setTareasHoras';
import setTareasEstado from '@salesforce/apex/Controlador.setTareasEstado';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TaskItem extends LightningElement {

    @api task;
    taskId;
    hours;
    @track beginTask = false;

    //check task status and change variable accordingly
    connectedCallback(){

        let taskStatus = this.task.Status__c;

        if(taskStatus == "In Progress"){

            this.beginTask = true;
        }

    }

    //button handler for task
    handleClick() {

        this.beginTask = true;
        
    }

    //assign values to variables
    handleHours(event){

        this.hours = event.target.value;
        this.taskId = event.target.taskValue;

    }

    //submit hours loaded to apex method and handle toasts
    handleSubmit() {
    
        console.log('boton');

        const taskTrack = { Id: this.taskId, Worked_Hours__c: this.hours };

        console.log(JSON.stringify(taskTrack));

        setTareasHoras( {  strJSON : JSON.stringify(taskTrack) } )
        .then((data)=>{

            console.log(data);

            const event = new ShowToastEvent({

                title: 'Success!',
                message: `You've succesfully updated the hours.`,
                variant: 'success'
            });
            this.dispatchEvent(event);
            
            //if successful, refresh apex and clear all fields
            this.dispatchEvent(new CustomEvent('refresh',{

                detail : { refresh : true },
                bubbles: true,
                composed: true
            }));

            this.template.querySelector('lightning-input').value = '';
            this.hours = 0;
        })
        .catch((error)=>{

            console.log('error');
            console.log(JSON.stringify(error));

            const event = new ShowToastEvent({

                title: `Error - Hours couldn't be updated.`,
                message: error.body.pageErrors[0].message,
                variant: 'error'
            });
            this.dispatchEvent(event);
        });

    }

    //mark task as completed and handle toasts
    handleCompleted() {
    
        console.log('boton');

        const taskTrack = { Id: this.taskId, Worked_Hours__c: this.hours };

        console.log(JSON.stringify(taskTrack));

        setTareasEstado({ strJSON: JSON.stringify(taskTrack) })
        .then((data)=>{

            console.log(data);

            const event = new ShowToastEvent({

                title: 'Task Completed!',
                message: `You've succesfully completed the task.`,
                variant: 'success'
            });
            this.dispatchEvent(event);

            //if successful, refresh apex and clear all fields
            this.dispatchEvent(new CustomEvent('refresh',{

                detail : { refresh : true },
                bubbles: true,
                composed: true
            }));

            this.template.querySelector('lightning-input').value = '';
            this.hours = 0;
        })
        .catch((error)=>{

            console.log('error');
            console.log(JSON.stringify(error));

            const event = new ShowToastEvent({

                title: `Error - Task couldn't be completed.`,
                message: error.body.pageErrors[0].message,
                variant: 'error'
            });
            this.dispatchEvent(event);
        });

    }

}