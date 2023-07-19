import { LightningElement, api } from 'lwc';

export default class ProjectCard extends LightningElement {

    @api tasks;
    @api project;

    // connectedCallback(){

    //     console.log('otra cosa');
    //     console.log(JSON.stringify(this.tasks));

    // }

}