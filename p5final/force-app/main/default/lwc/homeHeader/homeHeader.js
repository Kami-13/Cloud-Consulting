import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import UserName from '@salesforce/schema/User.Name';
import userAlias from '@salesforce/schema/User.Alias';
import logo from '@salesforce/resourceUrl/CloudConsultingLogo';

export default class HomeHeader extends LightningElement {

    @wire(CurrentPageReference)
    pageRef;

    userId = Id;
    formattedDate;
    currentUserName;
    currentUserAlias;

    ccLogo = logo;

    //get user info
    @wire(getRecord, { recordId: Id, fields: [ UserName, userAlias ]}) 

    userDetails({error, data}){

        if(data){

            this.currentUserName = data.fields.Name.value;
            this.currentUserAlias = data.fields.Alias.value;

        }else if (error){

            this.error = error ;
        }
    }

    //call function to set and format date
    connectedCallback(){

        this.setFormattedDate();
    }

    //format date
    setFormattedDate(){

        const today = new Date();

        const options = { year: 'numeric', month: 'long', day: 'numeric' };

        this.formattedDate = today.toLocaleDateString(undefined, options);
    }
}