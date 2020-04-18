import { LightningElement,api,track } from 'lwc';

export default class CreateChildCaseMaster extends LightningElement {
    @track caseList = [] ;
    @track index = 0;
    addRow() {

    var caseList = this.get("caseList");

       this.index++;
   
        this.caseList.push ({
            sobjectType: 'Case',
            Subject: ''
        });

        console.log('Enter ',caseList);
        console.log('Enter ',this.caseList); 

    }
}