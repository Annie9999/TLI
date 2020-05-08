import { LightningElement, api } from 'lwc';
import addSLATime from '@salesforce/apex/AddSLATimeCtrl.AddSLATime';
import getStatus from '@salesforce/apex/AddSLATimeCtrl.getStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import successAddTime from '@salesforce/label/c.Success_AddSLATime';


export default class TLI_lwc_AddSLATime extends LightningElement {

    @api recordId;
    lead;

    closeQuickAction(event) {
        event.preventDefault();
        // refreshApex(this.user);
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    AddTimeClick(){
        getStatus({ 
            leadId: this.recordId
        })
        .then(result =>{
            console.log('result = '+result);
            this.lead = result;
            console.log('record= '+this.lead.RecordType.Name);
            if((this.lead.RecordType.Name == 'สนใจเป็นตัวแทน' && this.lead.Status == 'ยืนยันการรับงาน') || 
                (this.lead.RecordType.Name == 'สนใจทำประกันผ่านตัวแทน' && (this.lead.Status == 'ยืนยันการรับงาน' || this.lead.Status == 'รอเข้าพบลูกค้า'))){
                addSLATime({
                    LeadId: this.recordId
                })
                .then(() => {
                    const evt = new ShowToastEvent({
                        title: successAddTime,
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CustomEvent('closeandrefresh'));
                    
                })
                .catch((error) => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: error,
                        //message: this.errorMsg,
                        variant: 'error',
                    }));
                })
            }
            else{
                console.log('resultElse'+this.status);
                const closeQA = new CustomEvent('close');
                this.dispatchEvent(closeQA);
                if(this.lead.RecordType.Name == 'สนใจทำประกันผ่านตัวแทน'){
                    this.dispatchEvent(new ShowToastEvent({
                        title: this.errorTitle,
                        message: 'ไม่สามารถเพิ่มเวลาได้ เนื่องจาก Lead Status ยังไม่ได้รับการยืนยันรับงาน หรือ รอเข้าพบลูกค้า',
                        variant: 'error',
                    }));
                }else if(this.lead.RecordType.Name == 'สนใจเป็นตัวแทน'){
                    this.dispatchEvent(new ShowToastEvent({
                        title: this.errorTitle,
                        message: 'ไม่สามารถเพิ่มเวลาได้ เนื่องจาก Lead Status ยังไม่ได้รับการยืนยันรับงาน',
                        variant: 'error',
                    }));
                }

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