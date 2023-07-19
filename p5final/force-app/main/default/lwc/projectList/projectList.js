import { LightningElement, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getProjectsByUser from '@salesforce/apex/ProjectsList.getProjectsByUser';
import { NavigationMixin } from 'lightning/navigation';

export default class ProjectList extends NavigationMixin (LightningElement) {

    userId = Id;
    refreshProjects;
    PM = false;
    SL = false;
    nothing = true;
    projectManager;
    squadLead;

    //wire user's projects
    @wire(getProjectsByUser, { userId: '$userId' })
    wiredResources( result ) {

        this.refreshProjects = result;

        const { error, data } = result;

        if(data){

            //check data to set variable values for html's if templates
            if(data.projectManagerProjects.length > 0){

                this.PM = true;
                this.nothing = false;

            }else if(data.squadLeadProjects.length > 0){

                this.SL = true;
                this.nothing = false;

            }
            
            //assign data to variables
            this.projectManager = data.projectManagerProjects;
            this.squadLead = data.squadLeadProjects;

        }else if(error){

            console.log(error);
        }
    }

    //set projectId and call navi function
    handleProjectClick(event){

        const projectId = event.target.dataset.projectId;
        console.log('Clicked project ID:', projectId);

        this.handleNavigation(projectId);
    }

    //navigation to clicked project
    handleNavigation(projectId) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: projectId,
                actionName: 'view'
            },
        });
    }

}