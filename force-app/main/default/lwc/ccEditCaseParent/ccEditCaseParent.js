import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Case_Information from '@salesforce/label/c.Case_Information';
import Contact_Information from '@salesforce/label/c.Contact_Information';
import labelAccount from '@salesforce/label/c.Account';
import labelContact from '@salesforce/label/c.Contact';
import labelSource from '@salesforce/label/c.Insurance_Policy';
import labelSave_Service_Request from '@salesforce/label/c.Save_Service_Request';
import filterMatrix_type from '@salesforce/apex/ccEditCaseParentCtrl.filterMatrix_type';
import filterMatrix_topic from '@salesforce/apex/ccEditCaseParentCtrl.filterMatrix_topic';
import filterMatrix_subject from '@salesforce/apex/ccEditCaseParentCtrl.filterMatrix_subject';
import filterMatrix_subSubject from '@salesforce/apex/ccEditCaseParentCtrl.filterMatrix_subSubject';
import filterMatrix_sla from '@salesforce/apex/ccEditCaseParentCtrl.filterMatrix_sla';
// import getPickListDivision from '@salesforce/apex/ccEditCaseParentCtrl.getPickListDivision';
// import getPickListSubDivision from '@salesforce/apex/ccEditCaseParentCtrl.getPickListSubDivision';
// import getPickListOrigin from '@salesforce/apex/ccEditCaseParentCtrl.getPickListOrigin';
// import getPickListStatus from '@salesforce/apex/ccEditCaseParentCtrl.getPickListStatus';

import listTypeMatrix from '@salesforce/apex/customNewCaseParentCtrl.listTypeMatrix';

import getfindPolicy from '@salesforce/apex/customNewCaseParentCtrl.findPolicy';

import getInfo from '@salesforce/apex/ccEditCaseParentCtrl.getInfo';
import save from '@salesforce/apex/ccEditCaseParentCtrl.save';

import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';

// import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Case.ContactId', 'Case.AccountId','Case.SourceId','MessagingSession.CaseId'];

export default class CcEditCaseParent extends LightningElement {
    @track label = {
        Case_Information,
        Contact_Information,
        labelAccount,
        labelContact,
        labelSource,
        labelSave_Service_Request
    };

    @api recordId;
    @api objectApiName;
    @api ObjectType;
    @api recTypeId;
    @api sObjectName;

    // Service Type Matrix
    @track lstService_All;

    @track labelService_Type; 
    @track listService_Type = [];
    @track mapService_Type = [];
    @track keyService_Type;
    @track getService_Type;
    @track isEmptyService_Type;

    @track labelService_Topic; 
    @track listService_Topic = [];
    @track mapService_Topic = [];
    @track keyService_Topic;
    @track getService_Topic;
    @track isEmptyService_Topic = false;

    @track labelService_Subject; 
    @track listService_Subject = [];
    @track mapService_Subject = [];
    @track keyService_Subject;
    @track getService_Subject;
    @track isEmptyService_Subject = false;

    @track labelService_Sub_Subject; 
    @track listService_Sub_Subject = [];
    @track mapService_Sub_Subject = [];
    @track keyService_Sub_Subject;
    @track getService_Sub_Subject;
    @track isEmptyService_Sub_Subject = false;

    @track getService_Status;
    @track getService_Origin;
    @track getService_Division;
    @track getService_SubDivision;
    @track isEmptySubDivision;
    @track isNonEmptySubDivision = true;

    @track mapSLA = [];
    @track keySLA;
    // Service Type Matrix

    @track lstRecordTypes;  // to store account record type list
    @track lstStatus;       // to store Rating field values (picklist)
    @track lstDivision = [];     //(picklist)
    @track lstSubDivision = [];  //(picklist)
    @track lstOrigin;       //(picklist)

    @track type = [];
    @track topic = [];
    @track subject = [];
    @track sub_subject = [];
    
    @track searchContactId;
    @track searchAccountId;
    @track searchSourceId;
    @track chooseDivision = null;
    @track chooseSubDivision = null;
    @track chooseOrigin = null;
    @track chooseStatus = null;
    @track chooseType = null;
    @track chooseTopic = null;
    @track chooseSubject = null;
    @track chooseSubSubject = null;
    @track getSLA = 0;

    controlSubDivisionValues;
    totalDependentValues = [];

    @track labelStatus;
    @track labelDivision;
    @track labelSubDivision;
    @track labelOrigin;
    @track labelSLA;

    @track isNonEmptyService_Topic = true;
    @track isNonEmptyService_Subject = true;
    @track isNonEmptyService_Sub_Subject = true;

    checkValidate = true;

    constructor(){
        super();
    }

    connectedCallback(){

        console.log('connectedCallback this.recordId : '+this.recordId);
        console.log('connectedCallback objectApiName : '+this.objectApiName);
        console.log('connectedCallback this.ObjectType : '+this.ObjectType);
        console.log('connectedCallback recTypeId : '+this.recTypeId);
        console.log('connectedCallback sObjectName : '+this.sObjectName);

        this.get_matrix();
        // this.get_type();
    }

    //Get select object
    //Set selected
    setSelectedValue(selectObj, valueToSet) {
        for (var i = 0; i < selectObj.options.length; i++) {
            if (selectObj.options[i].value== valueToSet) {
                selectObj.options[i].selected = true;
                return;
            }
        }
    }

    // get 3 field standard
    // @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    // wiredRecord({ error, data }) {
    //     console.log('getRecord error: ',error);
    //     console.log('getRecord data: ',data)
    //     if (error) {
    //         let message = 'Unknown error';
    //         if (Array.isArray(error.body)) {
    //             message = error.body.map(e => e.message).join(', ');
    //         } else if (typeof error.body.message === 'string') {
    //             message = error.body.message;
    //         }
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error loading Case',
    //                 message,
    //                 variant: 'error',
    //             }),
    //         );
    //     } else if (data) {
    //         this.searchContactId = data.fields.ContactId.value;
    //         this.searchAccountId = data.fields.AccountId.value;
    //         this.searchSourceId = data.fields.SourceId.value;
    //     }
    // }

    // get Case Object All Information from 'getObjectInfo' imported library 
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    wireCase({ data, error }) {
        if (data) {
            // console.log('data : ',data)
            this.labelService_Type = data.fields.Service_Type__c.label;
            this.labelService_Topic = data.fields.Service_Topic__c.label;
            this.labelService_Subject = data.fields.Service_Subject__c.label;
            this.labelService_Sub_Subject = data.fields.Service_Sub_Subject__c.label;
            this.labelStatus = data.fields.Status.label;
            this.labelDivision = data.fields.TLI_Division__c.label;
            this.labelSubDivision = data.fields.TLI_Subdivision__c.label;
            this.labelOrigin = data.fields.Origin.label;
            this.labelSLA = data.fields.SLA__c.label;
        }
        else if (error) {
            console.log("Error Occured ---> " + error);
        }
    }

    // fetch Case object all picklist fields based on recordTypeId
    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '$recTypeId'
    })
    wiredRecordTypeInfo({ data, error }) {
        if (data) {
            new Promise((resolve, reject) => {
                //========== Status ==========//
                this.lstStatus = data.picklistFieldValues.Status.values;
                this.getService_Status = 'งานใหม่';
                //========== Origin ==========//
                this.lstOrigin = data.picklistFieldValues.Origin.values;
                this.getService_Origin = 'โทรเข้า';
                //========== division ==========//
                let divisionOptions = [{label:'--ไม่มี--', value:null}];
                data.picklistFieldValues.TLI_Division__c.values.forEach(key => {
                    divisionOptions.push({
                        label : key.label,
                        value: key.value
                    })
                });
                this.lstDivision = divisionOptions;
                this.getService_Division = this.lstDivision[1].value;
                //========== SubDivision ==========//
                this.controlSubDivisionValues = data.picklistFieldValues.TLI_Subdivision__c.controllerValues;
                this.totalDependentValues = data.picklistFieldValues.TLI_Subdivision__c.values;
                this.isEmpty = false;
                let dependValues = [];
                this.dependentValues = new Array();

                if(this.getService_Division) {
                    
                    // filter the total dependent values based on selected country value 
                    this.totalDependentValues.forEach(conValues => {
                        if(conValues.validFor[0] === this.controlSubDivisionValues[this.getService_Division]) {
                            dependValues.push({
                                label: conValues.label,
                                value: conValues.value
                            })
                        }
                    })

                    this.lstSubDivision = dependValues;
                    if(this.lstSubDivision.length > 0){
                        this.isEmptySubDivision = false;
                    }else{
                        this.isEmptySubDivision = true;
                    }
                    this.isNonEmptySubDivision = !this.isEmptySubDivision;
                }
                resolve();
            })
            .then(() => {
                if(this.chooseDivision != null || this.chooseDivision != undefined || this.chooseDivision != 'undefined')
                this.getService_Division = this.chooseDivision;
                if(this.chooseSubDivision != null || this.chooseSubDivision != undefined || this.chooseSubDivision != 'undefined')
                this.getService_SubDivision = this.chooseSubDivision;
                var sub_division = this.getService_SubDivision;
                new Promise((resolve, reject) => {
                    this.Startup_stampDivision(this.getService_Division);
                    resolve();
                })
                .then(() => {
                    this.getService_SubDivision = sub_division;
                    if(this.getService_SubDivision != null || this.getService_SubDivision != undefined || this.getService_SubDivision != 'undefined'){
                        this.Startup_stampSubDivision(this.getService_SubDivision);
                    }
                })
            })
        }
        else if (error) {
            console.log("field Error Occured ---> " + JSON.stringify(error));
        }
    }

    set_data(){
        this.getService_Type = this.chooseType;
        this.getService_Topic = this.chooseTopic;
        this.getService_Subject = this.chooseSubject;
        this.getService_Sub_Subject = this.chooseSubSubject;

        var topic = this.getService_Topic;
        var subject = this.getService_Subject;
        var sub_subject = this.getService_Sub_Subject;
        var sla = this.getSLA;

        // Promise for wait all data finish
        new Promise((resolve, reject) => {
            this.Startup_Service_TypeChange(this.getService_Type);
            resolve();
        })
        .then(() => {
            new Promise((resolve, reject) => {
                this.Startup_Service_TopicChange(topic);
                resolve();
            })
            .then(() => {
                new Promise((resolve, reject) => {
                    this.Startup_Service_SubjectChange(subject);
                    resolve();
                })
                .then(() => {
                    new Promise((resolve, reject) => {
                        if(this.getService_Sub_Subject != null || this.getService_Sub_Subject != undefined || this.getService_Sub_Subject != 'undefined'){
                            this.Startup_Service_Sub_SubjectChange(sub_subject);
                        }
                        resolve();
                    })
                    .then(() => {
                        this.stampSLA(sla);
                    })
                })
            })
        })
    }

    get_matrix(){
        listTypeMatrix({})
        .then(result => {
            // Promise for wait all data finish
            new Promise((resolve, reject) => {
                this.lstService_All = result;
                for(let key in result) {
                    let Sub_SubjectNull = result[key].Service_Sub_Subject__c;
                    this.keyService_Type = result[key].Service_Type__c;
                    this.keyService_Topic = result[key].Service_Type__c;
                    this.keyService_Subject = result[key].Service_Type__c+'|'+result[key].Service_Topic__c;
                    this.keyService_Sub_Subject = result[key].Service_Type__c+'|'+result[key].Service_Topic__c+'|'+result[key].Service_Subject__c;
                    if(result[key].Service_Sub_Subject__c == undefined){
                        Sub_SubjectNull = null;
                    }
                    this.keySLA = result[key].Service_Type__c+'|'+result[key].Service_Topic__c+'|'+result[key].Service_Subject__c+'|'+Sub_SubjectNull;
    
                    if( this.mapService_Type[this.keyService_Type] == null || this.mapService_Type[this.keyService_Type] == ''){
                        this.mapService_Type[this.keyService_Type] = new Array();
                    }
                    if( this.mapService_Type[this.keyService_Type].indexOf(result[key].Service_Type__c) == -1
                    && result[key].Service_Type__c != '' && this.keyService_Type != '' ){
                        this.mapService_Type[this.keyService_Type].push(result[key].Service_Type__c);                
                    }
                    
                    if( this.mapService_Topic[this.keyService_Topic] == null || this.mapService_Topic[this.keyService_Topic] == ''){
                        this.mapService_Topic[this.keyService_Topic] = new Array();
                    }
                    if( this.mapService_Topic[this.keyService_Topic].indexOf(result[key].Service_Topic__c) == -1
                    && result[key].Service_Topic__c != '' && this.keyService_Topic != '' ){
                        this.mapService_Topic[this.keyService_Topic].push(result[key].Service_Topic__c);                
                    }
    
                    if( this.mapService_Subject[this.keyService_Subject] == null || this.mapService_Subject[this.keyService_Subject] == ''){
                        this.mapService_Subject[this.keyService_Subject] = new Array();
                    }
                    if( this.mapService_Subject[this.keyService_Subject].indexOf(result[key].Service_Subject__c) == -1
                    && result[key].Service_Subject__c != '' && this.keyService_Subject != '' ){
                        this.mapService_Subject[this.keyService_Subject].push(result[key].Service_Subject__c);                
                    }
    
                    if( this.mapService_Sub_Subject[this.keyService_Sub_Subject] == null || this.mapService_Sub_Subject[this.keyService_Sub_Subject] == ''){
                        this.mapService_Sub_Subject[this.keyService_Sub_Subject] = new Array();
                    }
                    if( this.mapService_Sub_Subject[this.keyService_Sub_Subject].indexOf(result[key].Service_Sub_Subject__c) == -1
                    && result[key].Service_Sub_Subject__c != '' && this.keyService_Sub_Subject != '' ){
                        this.mapService_Sub_Subject[this.keyService_Sub_Subject].push(result[key].Service_Sub_Subject__c);                
                    }
    
                    if( this.mapSLA[this.keySLA] == null || this.mapSLA[this.keySLA] == ''){
                        this.mapSLA[this.keySLA] = new Array();
                    }
                    if( this.mapSLA[this.keySLA].indexOf(result[key].SLA_min__c) == -1
                    && result[key].SLA_min__c != '' && this.keySLA != '' ){
                        this.mapSLA[this.keySLA].push(result[key].SLA_min__c);                
                    }
                    
                    
                }
                let listService_TypeOptions = [{label:'--ไม่มี--', value:null}];
                for(let key in this.mapService_Type) {
                    listService_TypeOptions.push({
                        label : key,
                        value: key
                    })
                }
                this.listService_Type = listService_TypeOptions;
                this.isNonEmptyService_Topic = !this.isEmptyService_Topic;
                this.isNonEmptyService_Subject = !this.isEmptyService_Subject;
                this.isNonEmptyService_Sub_Subject = !this.isEmptyService_Sub_Subject;
                //================== End Service_Type_Matrix ==================//
    
                resolve();
            })
            .then(() => {
                this.getInfo(this.recordId);
            })
        })
        .catch(error => {
            this.error = error;
        });
    }

    get_type(){
        filterMatrix_type({})
        .then(result => {
            // console.log('get type : ', result);

            // Promise for wait all data finish
            new Promise((resolve, reject) => {
                let listService_TopicOptions = [{label:'--ไม่มี--', value:null}];
                for(let key in result.set_topic) {
                    listService_TopicOptions.push({
                        label : result.set_topic[key],
                        value: result.set_topic[key]
                    })
                }
                this.listService_Topic = listService_TopicOptions;
                
                let listService_SubjectOptions = [{label:'--ไม่มี--', value:null}];
                for(let key in result.set_subject) {
                    listService_SubjectOptions.push({
                        label : result.set_subject[key],
                        value: result.set_subject[key]
                    })
                }
                this.listService_Subject = listService_SubjectOptions;

                let listService_SubSubjectOptions = [{label:'--ไม่มี--', value:null}];
                for(let key in result.set_subSubject) {
                    listService_SubSubjectOptions.push({
                        label : result.set_subSubject[key],
                        value: result.set_subSubject[key]
                    })
                }
                this.listService_Sub_Subject = listService_SubSubjectOptions;
                resolve();
            })
            .then(() => {
                this.set_data();
            })
        })
        .catch(error => {
            alert(error.message);
        });
    }

    get_topic(_type){
        filterMatrix_topic({type: _type})
        .then(result => {
            // console.log('get topic : ', result);
            this.topic = [];
            this.subject = [];
            this.sub_subject = [];

            if(result != null){
                for(let key in result.set_topic) {
                    this.topic.push(result.set_topic[key]);
                }
            }
            let topic = this.template.querySelector(`[data-id="service_topic"]`);
            let subject = this.template.querySelector(`[data-id="service_subject"]`);
            let sub_subject = this.template.querySelector(`[data-id="service_sub_subject"]`);
            if(this.topic.length > 0){
                topic.disabled = false;
            }else{
                topic.disabled = true;
            }
            subject.disabled = true;
            sub_subject.disabled = true;
        })
        .catch(error => {
            alert(error.message);
        });
    }

    get_subject(_type,_topic){
        filterMatrix_subject({type: _type, topic: _topic})
        .then(result => {
            // console.log('get subject : ', result);
            this.subject = [];
            this.sub_subject = [];
            if(result != null){
                for(let key in result.set_subject) {
                    this.subject.push(result.set_subject[key]);
                }
            }

            let subject = this.template.querySelector(`[data-id="service_subject"]`);
            let sub_subject = this.template.querySelector(`[data-id="service_sub_subject"]`);
            if(this.subject.length > 0){
                subject.disabled = false;
            }else{
                subject.disabled = true;
            }
            sub_subject.disabled = true;
        })
        .catch(error => {
            alert(error.message);
        });
    }

    get_sub_subject(_type,_topic,_subject){
        filterMatrix_subSubject({type: _type, topic: _topic,subject: _subject})
        .then(result => {
            // console.log('get sub-subject : ', result);
            this.sub_subject = [];
            for(let key in result.set_subSubject) {
                this.sub_subject.push(result.set_subSubject[key]);
            }
            this.getSLA = result.sla[0];

            let sub_subject = this.template.querySelector(`[data-id="service_sub_subject"]`);
            if(this.sub_subject.length > 0){
                sub_subject.disabled = false;
            }else{
                this.getSLA = result.sla[0];
                sub_subject.disabled = true;
            }
        })
        .catch(error => {
            alert(error.message);
        });
    }

    get_sla(_type,_topic,_subject,_sub_subject){
        filterMatrix_sla({type: _type, topic: _topic,subject: _subject,sub_subject: _sub_subject})
        .then(result => {
            // console.log('get sla : ', result);
            this.getSLA = result.sla[0];
            if(this.getSLA === '' || this.getSLA === null){
                this.getSLA = 0;
            }
        })
        .catch(error => {
            alert(error.message);
        });
    }

    getInfo(recordId){
        // console.log('recordId : ',recordId)
        getInfo({recordId: recordId})
        .then(result => {
            // console.log('getInfo : ', result);
            this.recordTypeId = result.RecordTypeId;

            this.chooseStatus = result.Status;
            this.chooseOrigin = result.Origin;
            this.chooseDivision = result.TLI_Division__c;
            this.chooseSubDivision = result.TLI_Subdivision__c;
            
            this.recTypeId = result.RecordTypeId;

            this.chooseType = result.Service_Type__c;
            this.chooseTopic = result.Service_Topic__c;
            this.chooseSubject = result.Service_Subject__c;
            this.chooseSubSubject = result.Service_Sub_Subject__c;

            if(result.SLA__c === '' || result.SLA__c === null || result.SLA__c === undefined){
                this.getSLA = 0;
            }
            else{
                this.getSLA = result.SLA__c;
            }

            this.get_type();
        })
        .catch(error => {
            console.log('ERROR : ',error);
        });
    }

    handleChange(event) {
        console.log("You selected an contact: " + event.detail.value[0]);
    }
    handleChangeAccount(event) {
        console.log("You selected an account: " + event.target.value);
        getfindPolicy({
            Id: event.target.value
        })
        .then(result => {
            this.searchSourceId = result.Id;
        })
        .catch(error => {
            console.log('ERROR : ',error);
            this.searchSourceId = '';
        });
    }

    StatusChange(event) {
        const field = event.target.name;
        if (field === 'StatusOption') {
            this.getService_Status = event.target.value;
        }
    }

    filterType(){
        let service_type = this.template.querySelector(`[data-id="service_type"]`);
        this.chooseType = service_type.value;
        this.get_topic(this.chooseType);
    }
    filterTopic(){
        let service_topic = this.template.querySelector(`[data-id="service_topic"]`);
        this.chooseTopic = service_topic.value;
        this.get_subject(this.chooseType,this.chooseTopic);
    }
    filterSubject(){
        let service_subject = this.template.querySelector(`[data-id="service_subject"]`);
        this.chooseSubject = service_subject.value;
        this.get_sub_subject(this.chooseType,this.chooseTopic,this.chooseSubject);
    }
    filterSubSubject(){
        let service_sub_subject = this.template.querySelector(`[data-id="service_sub_subject"]`);
        this.chooseSubSubject = service_sub_subject.value;
        this.get_sla(this.chooseType,this.chooseTopic,this.chooseSubject,this.chooseSubSubject);
    }

    //================== Start Service_Type_Matrix ==================//
    Service_TypeChange(event) {
        this.listService_Topic = new Array();
        this.listService_Subject = new Array();
        this.listService_Sub_Subject  = new Array();
        this.getService_Topic = null;
        this.getService_Subject = null;
        this.getService_Sub_Subject = null;
        this.getSLA = null;
        this.isEmptyService_Topic = true;
        this.isEmptyService_Subject = true;
        this.isEmptyService_Sub_Subject = true;
        const field = event.target.name;
        if (field === 'Service_TypeOption') {
            this.getService_Type = event.target.value;
            if(event.target.value != null){
                const keyMap = this.getService_Type;
                let listService_TopicOptions = [{label:'--ไม่มี--', value:null}];
                for(let key in this.mapService_Topic[keyMap]) {
                    listService_TopicOptions.push({
                        label : this.mapService_Topic[keyMap][key],
                        value: this.mapService_Topic[keyMap][key]
                    })
                }
                this.listService_Topic = listService_TopicOptions;

                if(this.listService_Topic.length > 0){
                    this.isEmptyService_Topic = false;
                }
            }
        }
        this.isNonEmptyService_Topic = !this.isEmptyService_Topic;
        this.isNonEmptyService_Subject = !this.isEmptyService_Subject;
        this.isNonEmptyService_Sub_Subject = !this.isEmptyService_Sub_Subject;
    }
    Service_TopicChange(event) {
        this.listService_Subject = new Array();
        this.listService_Sub_Subject  = new Array();
        this.getService_Subject = null;
        this.getService_Sub_Subject =  null;
        this.getSLA = null;
        this.isEmptyService_Subject = true;
        this.isEmptyService_Sub_Subject = true;
        const field = event.target.name;
        if (field === 'Service_TopicOption') {
            this.getService_Topic = event.target.value;
            if(event.target.value != null){
                const keyMap = this.getService_Type+'|'+this.getService_Topic;
                let listService_SubjectOptions = [{label:'--ไม่มี--', value:null}];
                for(let key in this.mapService_Subject[keyMap]) {
                    listService_SubjectOptions.push({
                        label : this.mapService_Subject[keyMap][key],
                        value: this.mapService_Subject[keyMap][key]
                    })
                }
                this.listService_Subject = listService_SubjectOptions;
                if(this.listService_Topic.length > 0){
                    this.isEmptyService_Subject = false;
                }
            }
        }
        this.isNonEmptyService_Topic = !this.isEmptyService_Topic;
        this.isNonEmptyService_Subject = !this.isEmptyService_Subject;
        this.isNonEmptyService_Sub_Subject = !this.isEmptyService_Sub_Subject;
    }
    Service_SubjectChange(event) {
        this.listService_Sub_Subject  = new Array();
        this.getService_Sub_Subject = null;
        this.getSLA = null;
        this.isEmptyService_Sub_Subject = true;
        const field = event.target.name;
        if (field === 'Service_SubjectOption') {
            this.getService_Subject = event.target.value;
            const keyMap = this.getService_Type+'|'+this.getService_Topic+'|'+this.getService_Subject;
            if(event.target.value != null){
                if(this.mapService_Sub_Subject[keyMap].length > 1){
                    let listService_Sub_SubjectOptions = [{label:'--ไม่มี--', value:null}];
                    for(let key in this.mapService_Sub_Subject[keyMap]) {
                        listService_Sub_SubjectOptions.push({
                            label : this.mapService_Sub_Subject[keyMap][key],
                            value: this.mapService_Sub_Subject[keyMap][key]
                        })
                    }
                    this.listService_Sub_Subject = listService_Sub_SubjectOptions;
                    if(this.listService_Sub_Subject.length > 0){
                        this.isEmptyService_Sub_Subject = false;
                    }
                }
                else{
                    let subSubject = this.getService_Sub_Subject;
                    if(this.getService_Sub_Subject == ''){
                        subSubject = null;
                    }
                    const keyMapSLA = this.getService_Type+'|'+this.getService_Topic+'|'+this.getService_Subject+'|'+subSubject;
                    if(this.mapSLA[keyMapSLA].length > 0){
                        this.getSLA = this.mapSLA[keyMapSLA][0];
                    }
                }
            }
        }
        this.isNonEmptyService_Topic = !this.isEmptyService_Topic;
        this.isNonEmptyService_Subject = !this.isEmptyService_Subject;
        this.isNonEmptyService_Sub_Subject = !this.isEmptyService_Sub_Subject;
    }
    Service_Sub_SubjectChange(event) {
        const field = event.target.name;
        this.getSLA = null;
        if (field === 'Service_Sub_SubjectOption') {
            this.getService_Sub_Subject = event.target.value;
            if(event.target.value != null){
                const keyMapSLA = this.getService_Type+'|'+this.getService_Topic+'|'+this.getService_Subject+'|'+this.getService_Sub_Subject;
                if(this.mapSLA[keyMapSLA].length > 0){
                    this.getSLA = this.mapSLA[keyMapSLA][0];
                }
            }
        }   
    }

    stampStatus(event){
        this.getService_Status = event.target.value;
    }
    stampOrigin(event){
        this.getService_Origin = event.target.value;
    }
    stampDivision(event){
        this.getService_Division = event.target.value;
        this.isEmpty = false;
        let dependValues = [];
        this.lstSubDivision = [];
        this.dependentValues = new Array();
        this.getService_SubDivision = null;
        if(this.getService_Division) {
            // if Selected country is none returns nothing
            if(this.getService_Division == null) {
                this.isEmpty = true;
                dependValues = [{label:'--ไม่มี--', value:null}];
                this.getService_Division = null;
                this.getService_SubDivision = null;
                return;
            }else{
                this.totalDependentValues.forEach(conValues => {
                    if(conValues.validFor[0] === this.controlSubDivisionValues[this.getService_Division]) {
                        dependValues.push({
                            label: conValues.label,
                            value: conValues.value
                        })
                    }
                })
            }

            // filter the total dependent values based on selected country value 
            

            this.lstSubDivision = dependValues;
            
        }
        if(this.lstSubDivision.length > 0){
            this.isEmptySubDivision = false;
        }else{
            this.isEmptySubDivision = true;
        }
        this.isNonEmptySubDivision = !this.isEmptySubDivision;
    }
    stampSubDivision(event){
        this.getService_SubDivision = event.target.value;
    }
    stampSLA(sla){
        this.getSLA = sla;
    }

    test(){
        alert('TEST');
    }

    save(){
        let contact = this.template.querySelector(`[data-id="contact"]`);
        let source = this.template.querySelector(`[data-id="source"]`);
        let account = this.template.querySelector(`[data-id="account"]`);
        let type = this.template.querySelector(`[data-id="service_type"]`);
        let topic = this.template.querySelector(`[data-id="service_topic"]`);
        let subject = this.template.querySelector(`[data-id="service_subject"]`);
        let sub_subject = this.template.querySelector(`[data-id="service_sub_subject"]`);
        let description = this.template.querySelector(`[data-id="description"]`);

        let listfieldError = [];

        if(this.getService_Type == null || this.getService_Type == undefined || this.getService_Type == 'undefined'){
            listfieldError.push(this.labelService_Type);
        }
        if(this.getService_Topic == null || this.getService_Topic == undefined || this.getService_Topic == 'undefined'){
            listfieldError.push(this.labelService_Topic);
        }
        if(this.getService_Subject == null || this.getService_Subject == undefined || this.getService_Subject == 'undefined' && this.listService_Subject.length > 0){
            listfieldError.push(this.labelService_Subject);
        }
        if(this.getService_Sub_Subject == null && this.listService_Sub_Subject.length > 0){
            listfieldError.push(this.labelService_Sub_Subject);
        }
        
        if(this.chooseDivision == null || this.chooseDivision == undefined || this.chooseDivision == 'undefined'){
            listfieldError.push(this.labelDivision);
        }
        if(this.chooseSubDivision == null || this.chooseSubDivision == undefined || this.chooseSubDivision == 'undefined'){
            listfieldError.push(this.labelSubDivision);
        }
        
        console.log('listfieldError.length : ',listfieldError.length);
        if(listfieldError.length > 0){
            console.log('checkValidate : false')
            this.checkValidate = false;
        }
        else{
            console.log('checkValidate : true')
            this.checkValidate = true;
        }

        if(contact.value == ''){
            contact.value = null;
        }
        if(account.value == ''){
            account.value = null;
        }
        if(source.value == ''){
            source.value = null;
        }

        console.log('this.recordId : ',this.recordId)
        console.log('contact.value : ',contact.value)
        console.log('source.value : ',source.value)
        console.log('account.value : ',account.value)
        console.log('this.chooseStatus : ',this.chooseStatus)
        console.log('type.value : ',type.value)
        console.log('topic.value : ',topic.value)
        console.log('subject.value : ',subject.value)
        console.log('sub_subject.value : ',sub_subject.value)
        console.log('this.chooseDivision : ',this.chooseDivision)
        console.log('this.chooseSubDivision : ',this.chooseSubDivision)
        console.log('this.chooseOrigin : ',this.chooseOrigin)
        console.log('description.value : ',description.value)
        console.log('this.getSLA : ',this.getSLA)


        if(this.checkValidate){
            save({
                recordId: this.recordId,
                contact: contact.value,
                source: source.value,
                account: account.value,
                status: this.chooseStatus,
                type: type.value,
                topic: topic.value,
                subject: subject.value,
                sub_subject: sub_subject.value, 
                division: this.chooseDivision, 
                subDivision: this.chooseSubDivision, 
                origin: this.chooseOrigin,
                description: description.value,
                SLA: this.getSLA
            })
            .then(result => {
                // console.log('save : ', result);

                // close Tab
                var close = {
                    close:true, 
                    recordCaseId: this.recordId
                };
                const closeclickedevt = new CustomEvent('closeclicked', {
                    detail: { close },
                });
                this.dispatchEvent(closeclickedevt);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.sObjectName + ' บันทึกสำเร็จ',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.error = error;
            });
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'กรุณากรอกข้อมูลให้ครบถ้วน',
                    message: listfieldError.join(', '),
                    variant: 'error',
                }),
            );
        }  
    }

    //---------------Matrix For retrieve data---------------//
    Startup_Service_TypeChange(event) {
        this.listService_Topic = new Array();
        this.listService_Subject = new Array();
        this.listService_Sub_Subject  = new Array();
        this.getService_Topic = null;
        this.getService_Subject = null;
        this.getService_Sub_Subject = null;
        this.getSLA = null;
        this.isEmptyService_Topic = true;
        this.isEmptyService_Subject = true;
        this.isEmptyService_Sub_Subject = true;

        if(event != null){
            const keyMap = event;
            let listService_TopicOptions = [{label:'--ไม่มี--', value:null}];
            for(let key in this.mapService_Topic[keyMap]) {
                listService_TopicOptions.push({
                    label : this.mapService_Topic[keyMap][key],
                    value: this.mapService_Topic[keyMap][key]
                })
            }
            this.listService_Topic = listService_TopicOptions;

            if(this.listService_Topic.length > 0){
                this.isEmptyService_Topic = false;
            }
        }
        this.isNonEmptyService_Topic = !this.isEmptyService_Topic;
        this.isNonEmptyService_Subject = !this.isEmptyService_Subject;
        this.isNonEmptyService_Sub_Subject = !this.isEmptyService_Sub_Subject;
    }
    Startup_Service_TopicChange(event) {
        this.listService_Subject = new Array();
        this.listService_Sub_Subject  = new Array();
        this.getService_Subject = null;
        this.getService_Sub_Subject =  null;
        this.getSLA = null;
        this.isEmptyService_Subject = true;
        this.isEmptyService_Sub_Subject = true;
        this.getService_Topic = event;

        if(event != null){

            const keyMap = this.getService_Type+'|'+this.getService_Topic;

            let listService_SubjectOptions = [{label:'--ไม่มี--', value:null}];
            for(let key in this.mapService_Subject[keyMap]) {
                listService_SubjectOptions.push({
                    label : this.mapService_Subject[keyMap][key],
                    value: this.mapService_Subject[keyMap][key]
                })
            }
            this.listService_Subject = listService_SubjectOptions;

            if(this.listService_Topic.length > 0){
                this.isEmptyService_Subject = false;
            }
        }
        this.isNonEmptyService_Topic = !this.isEmptyService_Topic;
        this.isNonEmptyService_Subject = !this.isEmptyService_Subject;
        this.isNonEmptyService_Sub_Subject = !this.isEmptyService_Sub_Subject;
    }
    Startup_Service_SubjectChange(event) {
        this.listService_Sub_Subject  = new Array();
        this.getService_Sub_Subject = null;
        this.getSLA = null;
        this.isEmptyService_Sub_Subject = true;
        this.getService_Subject = event;
        const keyMap = this.getService_Type+'|'+this.getService_Topic+'|'+this.getService_Subject;
        if(event != null){
            if((this.mapService_Sub_Subject[keyMap]).length > 1){
                let listService_Sub_SubjectOptions = [{label:'--ไม่มี--', value:null}];
                for(let key in this.mapService_Sub_Subject[keyMap]) {
                    listService_Sub_SubjectOptions.push({
                        label : this.mapService_Sub_Subject[keyMap][key],
                        value: this.mapService_Sub_Subject[keyMap][key]
                    })
                }
                this.listService_Sub_Subject = listService_Sub_SubjectOptions;
                if(this.listService_Sub_Subject.length > 0){
                    this.isEmptyService_Sub_Subject = false;
                }
            }
            else{
                let subSubject = this.getService_Sub_Subject;
                if(this.getService_Sub_Subject == ''){
                    subSubject = null;
                }
                const keyMapSLA = this.getService_Type+'|'+this.getService_Topic+'|'+this.getService_Subject+'|'+subSubject;
                if(this.mapSLA[keyMapSLA].length > 0){
                    this.getSLA = this.mapSLA[keyMapSLA][0];
                }
            }
        }
        this.isNonEmptyService_Topic = !this.isEmptyService_Topic;
        this.isNonEmptyService_Subject = !this.isEmptyService_Subject;
        this.isNonEmptyService_Sub_Subject = !this.isEmptyService_Sub_Subject;
    }
    Startup_Service_Sub_SubjectChange(event) {
        this.getSLA = null;
        this.getService_Sub_Subject = event;
        if(event != null){
            const keyMapSLA = this.getService_Type+'|'+this.getService_Topic+'|'+this.getService_Subject+'|'+this.getService_Sub_Subject;
            if(this.mapSLA[keyMapSLA].length > 0){
                this.getSLA = this.mapSLA[keyMapSLA][0];
            }
        }
    }

    Startup_stampDivision(event){
        this.getService_Division = event;

        this.isEmpty = false;
        let dependValues = [];
        this.lstSubDivision = [];
        this.dependentValues = new Array();
        this.getService_SubDivision = null;
            // if Selected country is none returns nothing
            if(this.getService_Division == null) {
                this.isEmpty = true;
                dependValues = [{label:'--ไม่มี--', value:null}];
                this.getService_Division = null;
                this.getService_SubDivision = null;
                return;
            }else{
                this.totalDependentValues.forEach(conValues => {
                    if(conValues.validFor[0] === this.controlSubDivisionValues[this.getService_Division]) {
                        dependValues.push({
                            label: conValues.label,
                            value: conValues.value
                        })
                    }
                })
            }

            // filter the total dependent values based on selected country value 
            

            this.lstSubDivision = dependValues;
        // }
        if(this.lstSubDivision.length > 0){
            this.isEmptySubDivision = false;
        }else{
            this.isEmptySubDivision = true;
        }
        this.isNonEmptySubDivision = !this.isEmptySubDivision;
    }

    Startup_stampSubDivision(event){
        this.getService_SubDivision = event;
    }
    //---------------For retrieve data---------------//
}