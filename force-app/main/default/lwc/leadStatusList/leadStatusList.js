import { LightningElement,wire } from 'lwc';
import getLeads from '@salesforce/apex/LeadLMSController.getLeadList';


export default class LeadStatusList extends LightningElement 
{
    @wire(getLeads) leadList;
}