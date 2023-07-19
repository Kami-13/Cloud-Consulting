import { LightningElement, api, wire } from 'lwc';
import getRecursos from '@salesforce/apex/Controlador.getRecursos';
import setRecursos from '@salesforce/apex/Controlador.setRecursos';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { loadStyle } from 'lightning/platformResourceLoader';
import ToastLine from '@salesforce/resourceUrl/ToastLine';
import { MessageContext, publish } from 'lightning/messageService';
import RMC from '@salesforce/messageChannel/ResourceMessageChannel__c';

export default class ResourceAllocations extends LightningElement {

    @api recordId;
    @wire(MessageContext)
    messageContext;

    isLoading = true;
    resources;
    project;
    users;
    userDates;
    preKickoff = false;
    notKickoff = false;
    clearGrandchildren;

    userToSendArray = [];

    //wire resources
    @wire(getRecursos, { proId: '$recordId' })
    wiredResources( result ) {

        this.refreshResources = result;

        const {data, error} = result;

        if(data){

            // console.log('acá estan los datos');
            // console.log(data);

            //assign data to variables
            this.project = data.proyecto;

            this.userDates = data.usuarios_id_fechas_map;

            this.resources = [];

            this.isLoading = false;

            console.log(this.project.Status__c);

            //check project status and change variables accordingly
            if(this.project.Status__c == "Pre-Kickoff"){

                this.preKickoff = true;

            }else{

                this.notKickoff = true;

            }

            //loop through resources' map to create object for child component
            for(let role in data.roles_usuarios_map){

                for(let prt of this.project.Project_Roles__r){

                    if(prt.Role__c == role){

                        const totalHours = prt.Quantity_Of_Hours__c;

                        for(let prh in data.roles_horas_asignadas_proyecto){

                            if(prh == role){
            
                                const assignedHours = data.roles_horas_asignadas_proyecto[role];
            
                                this.resources.push({ role: role, users: data.roles_usuarios_map[role], total: totalHours, hours: assignedHours });
                            }
                            
                        }
                    }
                }
                
            }

        }else if(error){

            console.error(error);
        }

    }

    //push selected user from grandchild component to user array to send
    handleUserToSendChange(event){

        const userToSend = event.detail;

        this.userToSendArray.push(userToSend);

        console.log(JSON.stringify(this.userToSendArray));

    }

    //delete user from array to send when checkbox in grandchild component is unchecked
    handleUserToDelete(event){

        const deleteUser = event.detail;

        const existingIndex = this.userToSendArray.find(element => element.userId == deleteUser);

        this.userToSendArray.splice(this.userToSendArray.indexOf(existingIndex), 1);

        console.log(JSON.stringify(this.userToSendArray));
    }

    //submit array to apex method and handle resulting toast event
    handleSubmit(){
    
        console.log('boton');

        console.log(JSON.stringify(this.userToSendArray));

        setRecursos({ strJSON: JSON.stringify(this.userToSendArray) })
        .then((data)=>{

            console.log(data);

            const event = new ShowToastEvent({

                title: 'Hours Allocated!',
                message: `You've succesfully allocated the resource/s.`,
                variant: 'success'
            });
            this.dispatchEvent(event);

            //when successful submission, refresh apex and call handler function
            refreshApex(this.refreshResources);

            this.handleSuccessfulSubmit();

        })
        .catch((error)=>{

            console.log('error');
            console.log(JSON.stringify(error));

            const event = new ShowToastEvent({

                title: `Error - Hour couldn't be allocated.`,
                message: error.body.pageErrors[0].message,
                variant: 'error'
            });
            this.dispatchEvent(event);
        });

    }

    //load style for toast line break
    renderedCallback() {

        loadStyle(this, ToastLine)
        .then(() => console.log('Files loaded.'))
        .catch(error => console.log("Error " + error.body.message))

    }

    //when successful submit, send message to clear grandchild components' fields
    handleSuccessfulSubmit() {

        const messagePayload = {

            clearInputs: true
        };

        publish(this.messageContext, RMC, {
            payload: messagePayload
        });

        console.log('mensaje enviado');
    }

}