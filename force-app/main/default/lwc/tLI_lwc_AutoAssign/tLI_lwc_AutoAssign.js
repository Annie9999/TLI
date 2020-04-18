import { LightningElement,api, wire,track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateGroup from '@salesforce/apex/getGroupController.updateGroup';
import getUserName from '@salesforce/apex/getGroupController.getUserName';

/*Label*/
import successAutoAssignMsg from '@salesforce/label/c.TLI_SUCCESS_AUTOASSIGN';
export default class tLI_lwc_AutoAssign extends LightningElement {
    @api recordId;
    @track user;
    // @wire(getUserName) user;
      
    connectedCallback(){
        refreshApex(this.user);
       // alert('alert jaaaaaa');
        getUserName()
        .then((result) => {
            this.user = result;
            console.log(result);

        })
        .catch((error) =>{

        });
        // this.user2 = this.user.data;
        //this.message(this.user2.Name);
    }
    
    closeQuickAction(event) {
        event.preventDefault();
        refreshApex(this.user);
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    updateClick(){
        console.log('recordId='+this.recordId);
        console.log('user=',JSON.stringify(this.user.Id));
        // event.preventDefault();
        updateGroup({
            recordId: this.recordId,
            userId: this.user.Id
        })
        .then((result) => {
            console.log('Success');
            refreshApex(this.user);
            const evt = new ShowToastEvent({
                title: successAutoAssignMsg,
                variant: 'success',
            });
            this.dispatchEvent(evt);
            this.dispatchEvent(new CustomEvent('closeandrefresh'));
            
        })
        .catch((error) => {
            console.log('error');
        });


    }

    
}