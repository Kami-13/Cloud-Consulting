import { LightningElement, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getVacationByUser from '@salesforce/apex/ProjectsList.getVacationByUser';
import { refreshApex } from '@salesforce/apex';

export default class VacationsList extends LightningElement {

    userId = Id;
    requests = false;
    nothing = true;
    requestList;

    //wire user's out of office requests
    @wire(getVacationByUser, { userId: '$userId' })
    wiredVacations(result){

        this.refreshRequests = result;

        const { error, data } = result;

        //verify data to change variable status
        if(data){

            if(data.length > 0){

                this.requests = true;
                this.nothing = false;

            }

            this.requestList = data;

            console.log(data);

        }else if(error){

            console.log(error);
        }
    }

    //refresh apex
    handleRefresh(){

        refreshApex(this.refreshRequests);
    }
}