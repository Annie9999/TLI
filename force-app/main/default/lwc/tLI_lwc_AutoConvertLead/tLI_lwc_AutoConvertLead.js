import { LightningElement,api,wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import convertLeadApex from '@salesforce/apex/TLI_AutoConvertLeadCtrl.convertLead';
import Id from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';

/*Label*/
import successConvertLeadMsg from '@salesforce/label/c.TLI_SUCCESS_CONVERT_LEAD';

export default class TLI_lwc_AutoConvertLead extends NavigationMixin(LightningElement) {
    @api recordId;
    @track user;
    message;
    ownerId = Id;
    accId;
    errorMsg;
    errorTitle;
    @track isShowSpinner;
    onClickConvertLead(){
        this.isShowSpinner = true;
        convertLeadApex({
            leadId: this.recordId,
            OwnerId: this.ownerId 
        })
        .then(result => { 
            console.log('result ',result);
            
            this.isShowSpinner = false;
            const evt = new ShowToastEvent({
                title: successConvertLeadMsg,
                // message: successConvertLeadMsg,
                variant: 'success',
            });
            this.accId = result.data.accountId;
            this.oppId = result.data.opportunityId;
            console.log('Account Id= '+this.accId);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.oppId,
                    actionName: 'view'
                }
            });
            
            console.log('Account Id After= ');
            this.dispatchEvent(evt);
            this.dispatchEvent(new CustomEvent('closeandrefresh'));
            
            return refreshApex(this.TLI_lwc_AutoConvertLead);

        })
        .catch((error) => {

            this.isShowSpinner = false;
            console.log('message : ',error);
            // console.log('message : ',error.body.message);
            if(error.body.pageErrors != undefined){
                this.errorTitle= error.body.pageErrors[0].message.split(':')[1];
                // this.errorMsg = error.body.pageErrors[0].message.split(':')[1];
            }else{
                this.errorTitle = error.body.message;
            }
            console.log('errorTitle : ',this.errorTitle);
            console.log('errorMsg : ',this.errorMsg);
            const evt = new ShowToastEvent({
                title: this.errorTitle,
                message: this.errorMsg,
                variant: 'error',
            });
            this.dispatchEvent(evt);
           
            // this.message = 'Error received: code' + error.errorCode + ', ' +
            //     'message ' + error.body.message;
            
            
        });



    }
   
    
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    
    
}