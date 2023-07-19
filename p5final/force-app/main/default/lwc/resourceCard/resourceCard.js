import { LightningElement, api } from 'lwc';

export default class ResourceCard extends LightningElement {

    @api role;
    @api totalHours;
    @api assignedHours;
    @api users;
    @api userDates;
    @api relatedProject;

}