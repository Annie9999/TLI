import { LightningElement,track,api,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sessionLabelAccount from '@salesforce/label/c.Account';
import sessionLabelSource from '@salesforce/label/c.Insurance_Policy';
import sessionLabelCreate_Case from '@salesforce/label/c.Save_Service_Request';
import saveAllChildCase from '@salesforce/apex/CustomNewChildRecordListCtrl.createChildCase';
import cloneParent from '@salesforce/apex/CustomNewChildRecordListCtrl.caseInfoByParent';
import getfindPolicy from '@salesforce/apex/CustomNewChildRecordListCtrl.findPolicy';

import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';

export default class CustomNewChildRecordList extends LightningElement {
    
    @api objectApiName;
    @api recordId;
    @api recordTypeId;
    @track keyIndex = 0;  
    @track error;
    @track message;
    @track hideIconRemove;
    @track getCloneParent;
    @track setChild;
    @track getrecordTypeId;
    // Reactive variables
    @track controllingValues = [];
    //@track dependentValues = [];
    @track selectedCountry;
    @track selectedState;
    // @track isEmpty = false;
    @track error;
    controlValues;
    totalDependentValues = [];
    
    @track caseRecList = [];
    
    label = {
        sessionLabelAccount,
        sessionLabelSource,
        sessionLabelCreate_Case
    };

    connectedCallback(){
        console.log(this.objectApiName);
        console.log(this.recordId);
        console.log(this.recordTypeId);
        
        cloneParent({
            Id: this.recordId
        })
        .then(result => {
            this.getCloneParent = result;
            this.setChild = this.getCloneParent;
            this.caseRecList = [];
            this.caseRecList.push ({            
                AccountId : this.setChild.AccountId,
                InsurePolicy : this.setChild.Insurance_Policy__c,
                TLI_Division : '',
                TLI_Subdivision: '',
                isEmpty: true,
                dependentValues:[]
                // TLI_Division : this.setChild.TLI_Division__c,
                // TLI_Subdivision: this.setChild.TLI_Subdivision__c,
            });
            this.getrecordTypeId = this.setChild.RecordTypeId;
            if(this.caseRecList.length > 1){
                this.hideIconRemove = true;
            }else{
                this.hideIconRemove = false;
            }
            console.log(this.getCloneParent.TLI_Division__c);
        })
        .catch(error => {
            this.error = error;
        });
        console.log('this.getrecordTypeId');
        console.log(this.getrecordTypeId);
    }

    //Add Row 
    
    changeHandler(event){       
       // alert(event.target.id.split('-'));
        console.log('Access key2:'+event.target.accessKey);
        console.log('id:'+event.target.id);
        console.log('value:'+event.target.value);    
        console.log('name:'+event.target.name);  
        console.log(this.caseRecList);     
        
        if(event.target.name==='ChildInsurePolicy'){
            this.caseRecList[event.target.accessKey].InsurePolicy = event.target.value;
        }
        console.log(this.caseRecList);
    }
    handleDivisionChange(event) {
        // Selected Country Value
        this.caseRecList[event.target.accessKey].isEmpty = true;
        let dependValues = [];
        //this.dependentValues = new Array();
        console.log('accessKey : '+event.target.accessKey);
        if(event.target.name==='ChildTLI_Division'){
            this.caseRecList[event.target.accessKey].TLI_Division = event.target.value;
            this.caseRecList[event.target.accessKey].TLI_Subdivision = null;
        }
        if(this.caseRecList[event.target.accessKey].TLI_Division) {
            // if Selected country is none returns nothing
            if(this.caseRecList[event.target.accessKey].TLI_Division === '--ไม่มี--') {
                dependValues = [{label:'--ไม่มี--', value:'--ไม่มี--'}];
                
                this.caseRecList[event.target.accessKey].isEmpty = true;
                this.caseRecList[event.target.accessKey].TLI_Division = null;
                this.caseRecList[event.target.accessKey].TLI_Subdivision = null;
                return;
            }

            // filter the total dependent values based on selected country value 
            this.totalDependentValues.forEach(conValues => {
                if(conValues.validFor[0] === this.controlValues[this.caseRecList[event.target.accessKey].TLI_Division]) {
                    dependValues.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            })

            //this.dependentValues = dependValues;
            this.caseRecList[event.target.accessKey].dependentValues = dependValues;
            if(dependValues.length > 0){
                this.caseRecList[event.target.accessKey].isEmpty = false;
            }
        }
        
        console.log('Enter ',this.caseRecList);
    }

    handleSubdivisionChange(event) {
        this.selectedState = event.target.value;
        if(event.target.name==='ChildTLI_Subdivision'){
            this.caseRecList[event.target.accessKey].TLI_Subdivision = event.target.value;
        }
    }

    handleChangeAccount(event) {
        console.log('Access key2:'+event.target.accessKey);
        console.log('id:'+event.target.id);
        console.log('value:'+event.target.value);    
        console.log('name:'+event.target.name);  
        console.log(this.caseRecList); 
        console.log(this.caseRecList[event.target.accessKey]);
        let getInsurePolicy;
        let getaccessKey = event.target.accessKey;
        if(event.target.name==='ChildAccountId'){
            this.caseRecList[event.target.accessKey].AccountId = event.target.value;
        }
        getfindPolicy({
            Id: event.target.value
        })
        .then(result => {
            getInsurePolicy = result;
            console.log('getInsurePolicy.Id : '+getInsurePolicy.Id);
            console.log('getaccessKey : '+getaccessKey);
            console.log(this.caseRecList);
            console.log(this.caseRecList[getaccessKey]);
            this.caseRecList[getaccessKey].InsurePolicy = getInsurePolicy.Id;
        })
        .catch(error => {
            this.error = error;
            this.caseRecList[getaccessKey].InsurePolicy = '';
        });
        
    }

    addRow() {
        this.keyIndex+1;   
        this.setChild = this.getCloneParent;
        console.log('Enter ',this.caseRecList);
        this.caseRecList.push ({            
            AccountId : this.setChild.AccountId,
            InsurePolicy : this.setChild.Insurance_Policy__c,
            TLI_Division : '',
            TLI_Subdivision: '',
            isEmpty: true,
            dependentValues:[]
            // TLI_Division : this.setChild.TLI_Division__c,
            // TLI_Subdivision: this.setChild.TLI_Subdivision__c,
        });
        if(this.caseRecList.length > 1){
            this.hideIconRemove = true;
        }else{
            this.hideIconRemove = false;
        }
        console.log('Enter ',this.caseRecList);
    }
    removeRow(event){       
        console.log('Access key2:'+event.target.accessKey);
        console.log(event.target.id.split('-')[0]);
        console.log(this.caseRecList);
        if(this.caseRecList.length>=1){             
             this.caseRecList.splice(event.target.accessKey,1);
             this.keyIndex-1;

             if(this.caseRecList.length > 1){
                this.hideIconRemove = true;
            }else{
                this.hideIconRemove = false;
            }
        }
    }  
    //Save Child
    saveMultipleChild() {
        let checkValidate = true;
        let listfieldEachError = [];
        let listfieldError = [];
        let countIndex = 1;
        console.log("childList"+JSON.stringify(this.caseRecList));
        this.caseRecList.forEach(function(item){    
            listfieldEachError = [];
            console.log('item.AccountId : '+item.AccountId == '');
            console.log('item.TLI_Division : '+item.TLI_Division);
            console.log('item.TLI_Subdivision : '+item.TLI_Subdivision);
            // if(!(item.AccountId  && item.TLI_Division && item.TLI_Subdivision)){
            //     console.log(item.AccountId  && item.TLI_Division && item.TLI_Subdivision);
                
                if(item.AccountId == null || item.AccountId == ''){
                    console.log('this.label.sessionLabelAccount : '+sessionLabelAccount);
                    listfieldEachError.push(sessionLabelAccount);
                }
                if(item.TLI_Division == null || item.TLI_Division == ''){
                    console.log('this.TLI_Division : '+'สายงาน');
                    listfieldEachError.push('สายงาน');
                }
                if((item.TLI_Subdivision == null || item.TLI_Subdivision == '') && item.dependentValues.length > 0){
                    console.log('this.TLI_Subdivision : '+'ส่วนงาน');
                    listfieldEachError.push('ส่วนงาน');
                }
            // }  
            if(listfieldEachError.length > 0){
                listfieldError.push('[ '+countIndex+' ] : '+listfieldEachError.join(', '));
            } 
            countIndex++;
            
        });
        if(listfieldError.length > 0){
            checkValidate = false;
        }  
        console.log('checkValidate : '+checkValidate);
        if(checkValidate){
            console.log(this.caseRecList);
            let caseRecListInsert = [];
            this.caseRecList.forEach(function(item){    
                
                caseRecListInsert.push ({            
                    AccountId : item.AccountId,
                    InsurePolicy : item.InsurePolicy,
                    TLI_Division : item.TLI_Division,
                    TLI_Subdivision: item.TLI_Subdivision
                });             
            });
            console.log(caseRecListInsert);
            saveAllChildCase({ childList : caseRecListInsert,parent : this.getCloneParent })
                .then(result => {
                    this.message = result;
                    this.error = undefined;                
                    // this.caseRecList.forEach(function(item){                   
                    //     item.AccountId='';
                    //     item.InsurePolicy='';
                    //     item.TLI_Division='';
                    //     item.TLI_Subdivision='';
                    // });

                    this.caseRecList = new Array();
                    this.caseRecList.push ({            
                        AccountId : this.setChild.AccountId,
                        InsurePolicy : this.setChild.Insurance_Policy__c,
                        TLI_Division : '',
                        TLI_Subdivision: '',
                        isEmpty: true,
                        dependentValues:[]
                        // TLI_Division : this.setChild.TLI_Division__c,
                        // TLI_Subdivision: this.setChild.TLI_Subdivision__c,
                    });
                    if(this.message !== undefined) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'สำเร็จ',
                                message: 'สร้างงานบริการย่อยสำเร็จ!',
                                variant: 'success',
                            }),
                        );
                    }

                    console.log(JSON.stringify(result));
                    console.log("result", this.message);
                })
                .catch(error => {
                    this.message = undefined;
                    this.error = error;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating records',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                    console.log("error", JSON.stringify(this.error));
                });
        }else{
            // for(let each in listfieldError){
            //     this.dispatchEvent(
            //         new ShowToastEvent({
            //             // title: 'กรุณากรอกข้อมูลให้ครบถ้วน',
            //             message: 'กรุณากรอกข้อมูลให้ครบถ้วน '+listfieldError[each],
            //             //message: listfieldError.join(' \n '),
            //             //message: 'Hello i am Second statement \r\n Hello i am Third statement',
            //             variant: 'error',
            //         }),
            //     );
            // }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'กรุณากรอกข้อมูลให้ครบถ้วน',
                    //message: 'กรุณากรอกข้อมูลให้ครบถ้วน '+listfieldError[each],
                    message: listfieldError.join(' , '),
                    //message: 'Hello i am Second statement \r\n Hello i am Third statement',
                    variant: 'error',
                }),
            );
            
        }
    }

    

    // Case object info
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;

    // Picklist values based on record type
    @wire(getPicklistValuesByRecordType, { 
        objectApiName: CASE_OBJECT 
        ,recordTypeId: '$getrecordTypeId'
    })
    countryPicklistValues({ data, error }) {
        if(data) {
            this.error = null;

            let countyOptions = [{label:'--ไม่มี--', value:'--ไม่มี--'}];
            //let countyOptions = [];

            // Account Country Control Field Picklist values
            data.picklistFieldValues.TLI_Division__c.values.forEach(key => {
                countyOptions.push({
                    label : key.label,
                    value: key.value
                })
                this.selectedCountry = key.value;
            });
            
            this.controllingValues = countyOptions;

            let stateOptions = [{label:'--ไม่มี--', value:'--ไม่มี--'}];

             // Account State Control Field Picklist values
            this.controlValues = data.picklistFieldValues.TLI_Subdivision__c.controllerValues;
            // Account State dependent Field Picklist values
            this.totalDependentValues = data.picklistFieldValues.TLI_Subdivision__c.values;

            this.totalDependentValues.forEach(key => {
                stateOptions.push({
                    label : key.label,
                    value: key.value
                })
            });
            //this.caseRecList[event.target.accessKey].dependentValues = stateOptions;
            console.log('countryPicklistValues this.dependentValues');
            //this.dependentValues = stateOptions;
            
            // this.caseRecList.forEach(function(item){
            //     item.dependentValues = stateOptions;
            // });   
        }
        else if(error) {
            this.error = JSON.stringify(error);
        }
    }

    

}