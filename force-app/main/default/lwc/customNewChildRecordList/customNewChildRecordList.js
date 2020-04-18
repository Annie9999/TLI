import { LightningElement,track,api,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
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
    //@track caseRecListInsert = [];

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
                SourceId : this.setChild.SourceId,
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
        
        if(event.target.name==='ChildSourceId'){
            this.caseRecList[event.target.accessKey].SourceId = event.target.value;
        }
        console.log(this.caseRecList);
    }
    handleDivisionChange(event) {
        // Selected Country Value
        this.caseRecList[event.target.accessKey].isEmpty = false;
        let dependValues = [];
        //this.dependentValues = new Array();
        console.log('accessKey : '+event.target.accessKey);
        if(event.target.name==='ChildTLI_Division'){
            this.caseRecList[event.target.accessKey].TLI_Division = event.target.value;
            this.caseRecList[event.target.accessKey].TLI_Subdivision = null;
        }
        if(this.caseRecList[event.target.accessKey].TLI_Division) {
            // if Selected country is none returns nothing
            if(this.caseRecList[event.target.accessKey].TLI_Division === '--None--') {
                dependValues = [{label:'--None--', value:'--None--'}];
                
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
        let getSourceId;
        let getaccessKey = event.target.accessKey;
        if(event.target.name==='ChildAccountId'){
            this.caseRecList[event.target.accessKey].AccountId = event.target.value;
        }
        getfindPolicy({
            Id: event.target.value
        })
        .then(result => {
            getSourceId = result;
            console.log('getSourceId.Id : '+getSourceId.Id);
            console.log('getaccessKey : '+getaccessKey);
            console.log(this.caseRecList);
            console.log(this.caseRecList[getaccessKey]);
            this.caseRecList[getaccessKey].SourceId = getSourceId.Id;
        })
        .catch(error => {
            this.error = error;
            this.caseRecList[getaccessKey].SourceId = '';
        });
        
    }

    addRow() {
        this.keyIndex+1;   
        this.setChild = this.getCloneParent;
        console.log('Enter ',this.caseRecList);
        this.caseRecList.push ({            
            AccountId : this.setChild.AccountId,
            SourceId : this.setChild.SourceId,
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
        console.log("childList"+JSON.stringify(this.caseRecList));
        this.caseRecList.forEach(function(item){    
            console.log(item.AccountId);
            console.log(item.SourceId);
            console.log(item.TLI_Division);
            console.log(item.TLI_Subdivision);
            console.log(item.AccountId && item.SourceId && item.TLI_Division && item.TLI_Subdivision);
            if(!(item.AccountId && item.SourceId && item.TLI_Division && item.TLI_Subdivision)){
                checkValidate = false;
            }               
        });
        console.log('checkValidate : '+checkValidate);
        if(checkValidate){
            console.log(this.caseRecList);
            let caseRecListInsert = [];
            this.caseRecList.forEach(function(item){    
                
                caseRecListInsert.push ({            
                    AccountId : item.AccountId,
                    SourceId : item.SourceId,
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
                    //     item.SourceId='';
                    //     item.TLI_Division='';
                    //     item.TLI_Subdivision='';
                    // });

                    this.caseRecList = new Array();
                    this.caseRecList.push ({            
                        AccountId : this.setChild.AccountId,
                        SourceId : this.setChild.SourceId,
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
                                title: 'Success',
                                message: 'Accounts Created!',
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
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'กรุณากรอกข้อมูลให้ครบถ้วน',
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

            let countyOptions = [{label:'--None--', value:'--None--'}];
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

            let stateOptions = [{label:'--None--', value:'--None--'}];

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
            this.caseRecList.forEach(function(item){
                item.dependentValues = stateOptions;
            });   
        }
        else if(error) {
            this.error = JSON.stringify(error);
        }
    }

    

}