import { LightningElement,api } from 'lwc';
import ReceiveLead from '@salesforce/apex/TLI_ReceiveLeadCtrl.ReceiveLead';
import ReAssign from '@salesforce/apex/TLI_ReceiveLeadCtrl.ReAssign';
import getStatus from '@salesforce/apex/TLI_ReceiveLeadCtrl.getStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TLI_lwc_ReceiveLead extends LightningElement {

    @api recordId;
    status;
    errorMsg;
    errorTitle;

    onClickReceiveLead(){
        getStatus({
            leadId: this.recordId
        })
        .then(result =>{
            this.status = result;
            if(this.status == 'มอบหมายงานให้ตัวแทนแล้ว'){
                ReceiveLead({
                    LeadId: this.recordId
                })
                .then(result =>{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'ยืนยันการรับงาน',
                        // message: successConvertLeadMsg,
                        variant: 'success',
                    }));
                })
                .catch((error) =>{
                    this.dispatchEvent(new ShowToastEvent({
                        title: error,
                        //message: this.errorMsg,
                        variant: 'error',
                    }));
                })
                .finally(()=>{
                    this.closeandrefreshAction();
                })
            }else{
                console.log('resultElse'+this.status);
                const closeQA = new CustomEvent('close');
                this.dispatchEvent(closeQA);
                this.dispatchEvent(new ShowToastEvent({
                    title: this.errorTitle,
                    message: 'ไม่สามารถรับงานได้ เนื่องจาก Lead Status ยังไม่ได้มอบหมายงาน',
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

    closeandrefreshAction(){
        const closeandrefresh = new CustomEvent('closeandrefresh');
        this.dispatchEvent(closeandrefresh);
    }

    closeQuickAction() {
        ReAssign({
            LeadId: this.recordId
        })
        .then(result =>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'ส่งคืนผู้มุ่งหวังแล้ว',
                // message: successConvertLeadMsg,
                variant: 'success',
            }));
        })
        .catch((error) =>{
            this.dispatchEvent(new ShowToastEvent({
                title: error,
                //message: this.errorMsg,
                variant: 'error',
            }));
        })
        .finally(()=>{
            this.closeandrefreshAction();
        })
    }
}