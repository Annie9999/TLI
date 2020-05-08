import { LightningElement,api, wire,track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateGroup from '@salesforce/apex/getGroupController.updateGroup';
import getUserName from '@salesforce/apex/getGroupController.getUserName';
import getStatus from '@salesforce/apex/getGroupController.getStatus';

/*Label*/
import successAutoAssignMsg from '@salesforce/label/c.TLI_SUCCESS_AUTOASSIGN';
export default class tLI_lwc_AutoAssign extends LightningElement {
    @api recordId;
    @track user;
    status;
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
        getStatus({
            leadId: this.recordId
        })
        .then(result =>{
            this.status = result;
            if(this.status == 'อยู่ระหว่างดำเนินการ'){
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
                })
            }else{
                console.log('resultElse'+this.status);
                const closeQA = new CustomEvent('close');
                this.dispatchEvent(closeQA);
                this.dispatchEvent(new ShowToastEvent({
                    title: this.errorTitle,
                    message: 'ไม่สามารถ Assign ได้ เนื่องจาก Lead Status ไม่ได้อยู่ระหว่างดำเนินการ',
                    variant: 'error',
                }));
            }
        })
        .catch((error) => {

            this.isShowSpinner = false;
            if(error.body.pageErrors != undefined){
                this.errorTitle= error.body.pageErrors[0].message.split(':')[1];
            }else{
                this.errorTitle = error.body.message;
            }
           const evt = new ShowToastEvent({
                title: this.errorTitle,
                message: this.errorMsg,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            
        });




    }

    
}