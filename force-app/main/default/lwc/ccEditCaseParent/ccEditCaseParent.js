import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Case_Information from '@salesforce/label/c.Case_Information';
import Contact_Information from '@salesforce/label/c.Contact_Information';
import filterMatrix_type from '@salesforce/apex/ccEditCaseParentCtrl.filterMatrix_type';
import filterMatrix_topic from '@salesforce/apex/ccEditCaseParentCtrl.filterMatrix_topic';
import filterMatrix_subject from '@salesforce/apex/ccEditCaseParentCtrl.filterMatrix_subject';
import filterMatrix_subSubject from '@salesforce/apex/ccEditCaseParentCtrl.filterMatrix_subSubject';
import filterMatrix_sla from '@salesforce/apex/ccEditCaseParentCtrl.filterMatrix_sla';
import getPickListDivision from '@salesforce/apex/ccEditCaseParentCtrl.getPickListDivision';
import getPickListSubDivision from '@salesforce/apex/ccEditCaseParentCtrl.getPickListSubDivision';
import getPickListOrigin from '@salesforce/apex/ccEditCaseParentCtrl.getPickListOrigin';
import getPickListStatus from '@salesforce/apex/ccEditCaseParentCtrl.getPickListStatus';

import listTypeMatrix from '@salesforce/apex/customNewCaseParentCtrl.listTypeMatrix';

import getfindPolicy from '@salesforce/apex/customNewCaseParentCtrl.findPolicy';

import getInfo from '@salesforce/apex/ccEditCaseParentCtrl.getInfo';
import save from '@salesforce/apex/ccEditCaseParentCtrl.save';

import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';

export default class CcEditCaseParent extends LightningElement {
    @track label = {
        Case_Information,
        Contact_Information
    };

    @api recordId;
    @api objectApiName;
    @api ObjectType;
    @api recordTypeId;

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

    @track getService_Origin;
    @track getService_SubDivision;
    @track getService_Division;

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

    @track labelService_Type;
    @track labelService_Topic;
    @track labelService_Subject;
    @track labelService_Sub_Subject;
    @track labelStatus;
    @track labelDivision;
    @track labelSubDivision;
    @track labelOrigin;
    @track labelSLA;

    handleSuccess(event) {
        // close Tab
        var close = {
            close:true, 
            recordCaseId:event.detail.id
        };
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
        this.dispatchEvent(closeclickedevt);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: event.detail.apiName + ' updated.',
                variant: 'success',
            }),
        );
    }

    constructor(){
        super();
        // console.log('labelName : ',this.labelName);
    }

    connectedCallback(){

        console.log('connectedCallback this.ObjectType : '+this.ObjectType);
        console.log('connectedCallback this.recordId : '+this.recordId);
        console.log('connectedCallback objectApiName : '+this.objectApiName);
        
        this.get_matrix();
        // this.get_type();
    }

    //Get select object
    // var objSelect = document.getElementById("Mobility");
    //Set selected
    setSelectedValue(selectObj, valueToSet) {
        for (var i = 0; i < selectObj.options.length; i++) {
            if (selectObj.options[i].value== valueToSet) {
                selectObj.options[i].selected = true;
                return;
            }
        }
    }

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
    // fetch account object all picklist fields based on recordTypeId
    
    // @wire(getPicklistValuesByRecordType, {
    //     objectApiName: CASE_OBJECT,
    //     recordTypeId: '$recordTypeId'
    // })
    // wiredRecordTypeInfo({ data, error }) {
    //     if (data) {
    //         // set lstStatuss property with Rating field Picklist values from returned data
    //         this.lstStatus = data.picklistFieldValues.Status.values;
    //     }
    //     else if (error) {
    //         console.log("field Error Occured ---> " + JSON.stringify(error));
    //     }
    // }

    // fetch Case object all picklist fields based on recordTypeId
    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '$recordTypeId'
    })
    wiredRecordTypeInfo({ data, error }) {
        if (data) {
            //========== Status ==========//
            this.lstStatus = data.picklistFieldValues.Status.values;
            this.getstatus = 'งานใหม่';
            //========== division ==========//
            this.lstOrigin = data.picklistFieldValues.Origin.values;
            let divisionOptions = [{label:'--None--', value:'--None--'}];
            data.picklistFieldValues.TLI_Division__c.values.forEach(key => {
                // console.log(key);
                divisionOptions.push({
                    label : key.label,
                    value: key.value
                })
            });
            this.lstDivision = divisionOptions;
            //========== SubDivision ==========//
            let subDivisionOptions = [{label:'--None--', value:'--None--'}];
            this.controlSubDivisionValues = data.picklistFieldValues.TLI_Subdivision__c.controllerValues;
            this.totalDependentValues = data.picklistFieldValues.TLI_Subdivision__c.values;

            this.totalDependentValues.forEach(key => {
                // console.log(key);
                subDivisionOptions.push({
                    label : key.label,
                    value: key.value
                })
            });
            this.lstSubDivision = subDivisionOptions;
            console.log('lstSubDivision : ',lstSubDivision)
        }
        else if (error) {
            console.log("field Error Occured ---> " + JSON.stringify(error));
        }
    }

    set_data(){
        // this.setSelectedValue(status, this.chooseStatus)

        // let type = this.template.querySelector(`[data-id="service_type"]`);
        // if(this.chooseType == null){
        //     type.value = '';
        // }
        // else{
        //     type.value = this.chooseType;
        // }
        
        // let topic = this.template.querySelector(`[data-id="service_topic"]`);
        // if(this.chooseTopic == null){
        //     topic.value = '';
        // }
        // else{
        //     topic.value = this.chooseTopic;
        // }

        // let subject = this.template.querySelector(`[data-id="service_subject"]`);
        // if(this.chooseSubject == null){
        //     subject.value = '';
        // }
        // else{
        //     subject.value = this.chooseSubject;
        // }

        // let sub_subject = this.template.querySelector(`[data-id="service_sub_subject"]`);
        // if(this.chooseSubSubject == null){
        //     sub_subject.value = '';
        // }
        // else{
        //     sub_subject.value = this.chooseSubSubject;
        // }
        this.getService_Type = this.chooseType;
        this.getService_Topic = this.chooseTopic;
        this.getService_Subject = this.chooseSubject;
        this.getService_Sub_Subject = this.chooseSubSubject;
    }

    get_matrix(){
        listTypeMatrix({})
        .then(result => {
            // Promise for wait all data finish
            new Promise((resolve, reject) => {
                this.lstService_All = result;
                console.log(this.lstService_All);
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
                //this.listService_Type = this.mapService_Type.value;
                //console.log(this.listService_Type);
                console.log(this.mapService_Type);
                console.log(this.mapService_Topic);
                console.log(this.mapService_Subject);
                console.log(this.mapService_Sub_Subject);
                console.log(this.mapSLA);
                let listService_TypeOptions = [{label:'--None--', value:null}];
                for(let key in this.mapService_Type) {
                    console.log(key);
                    listService_TypeOptions.push({
                        label : key,
                        value: key
                    })
                }
                this.listService_Type = listService_TypeOptions;
                console.log(this.listService_Type);
                //================== End Service_Type_Matrix ==================//
                resolve();
            })
            .then(() => {
                this.getInfo(this.recordId);
                throw new Error('Something failed');
            })
        })
        .catch(error => {
            this.error = error;
        });
    }

    get_type(){
        filterMatrix_type({})
        .then(result => {
            console.log('get type : ', result);
            // this.type = [];
            // this.topic = [];
            // this.subject = [];
            // this.sub_subject = [];
            
            // Promise for wait all data finish
            new Promise((resolve, reject) => {
                // console.log('Initial');
                // for(let key in result.set_type) {
                //     this.type.push(result.set_type[key]);
                // }
                let listService_TopicOptions = [{label:'--None--', value:null}];
                for(let key in result.set_topic) {
                    listService_TopicOptions.push({
                        label : result.set_topic[key],
                        value: result.set_topic[key]
                    })
                }
                this.listService_Topic = listService_TopicOptions;
                
                // for(let key in result.set_topic) {
                //     console.log('topic : ',result.set_topic[key])
                //     this.listService_Topic.push(result.set_topic[key]);
                // }
                
                let listService_SubjectOptions = [{label:'--None--', value:null}];
                for(let key in result.set_subject) {
                    listService_SubjectOptions.push({
                        label : result.set_subject[key],
                        value: result.set_subject[key]
                    })
                }
                this.listService_Subject = listService_SubjectOptions;

                // for(let key in result.set_subject) {
                //     this.listService_Subject.push(result.set_subject[key]);
                // }

                let listService_SubSubjectOptions = [{label:'--None--', value:null}];
                for(let key in result.set_subSubject) {
                    listService_SubSubjectOptions.push({
                        label : result.set_subSubject[key],
                        value: result.set_subSubject[key]
                    })
                }
                this.listService_Sub_Subject = listService_SubSubjectOptions;

                // for(let key in result.set_subSubject) {
                //     this.listService_Sub_Subject.push(result.set_subSubject[key]);
                // }
                resolve();
            })
            .then(() => {
                this.set_data();
            })


            // let type = this.template.querySelector(`[data-id="service_type"]`);
            // console.log('select type : ',this.chooseType);
            // type.value = this.chooseType;
        })
        .catch(error => {
            alert(error.message);
        });
    }

    get_topic(_type){
        filterMatrix_topic({type: _type})
        .then(result => {
            console.log('get topic : ', result);
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
            console.log('get subject : ', result);
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
            console.log('get sub-subject : ', result);
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
            console.log('get sla : ', result);
            this.getSLA = result.sla[0];
            if(this.getSLA === '' || this.getSLA === null){
                this.getSLA = 0;
            }
            console.log('se SLA : ',this.getSLA);
        })
        .catch(error => {
            alert(error.message);
        });
    }

    getInfo(recordId){
        getInfo({recordId: recordId})
        .then(result => {
            // console.log('getInfo : ', result);
            this.recordTypeId = result.RecordTypeId;
            // let status = this.template.querySelector(`[data-id="status"]`);
            // let type = this.template.querySelector(`[data-id="service_type"]`);
            let topic = this.template.querySelector(`[data-id="service_topic"]`);
            let subject = this.template.querySelector(`[data-id="service_subject"]`);
            let sub_subject = this.template.querySelector(`[data-id="service_sub_subject"]`);

            this.chooseStatus = result.Status;
            this.chooseOrigin = result.Origin;
            this.chooseDivision = result.TLI_Division__c;
            this.chooseSubDivision =  result.TLI_Subdivision__c;

            this.chooseType = result.Service_Type__c;
            this.chooseTopic = result.Service_Topic__c;
            this.chooseSubject = result.Service_Subject__c;
            this.chooseSubSubject = result.Service_Sub_Subject__c;

            console.log('result.SLA__c : ',result.SLA__c)
            if(result.SLA__c === '' || result.SLA__c === null || result.SLA__c === undefined){
                this.getSLA = 0;
            }
            else{
                this.getSLA = result.SLA__c;
            }

            // if(this.chooseTopic != null){
            //     topic.disabled = false;
            // }

            // if(this.chooseSubject != null){
            //     subject.disabled = false;
            // }

            // if(this.chooseSubSubject != null){
            //     sub_subject.disabled = false;
            // }

            this.get_type();
        })
        .catch(error => {
            alert(error.message);
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
            console.log('handleChangeAccount : ',result)
            this.searchSourceId = result.Id;
        })
        .catch(error => {
            this.error = error;
            this.searchSourceId = '';
        });
    }

    StatusChange(event) {
        const field = event.target.name;
        if (field === 'StatusOption') {
            this.getstatus = event.target.value;
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
        this.getService_Topic = '';
        this.getService_Subject = '';
        this.getService_Sub_Subject = '';
        this.getSLA = '';
        this.isEmptyService_Topic = true;
        this.isEmptyService_Subject = true;
        this.isEmptyService_Sub_Subject = true;
        const field = event.target.name;
        if (field === 'Service_TypeOption') {
            this.getService_Type = event.target.value;
            console.log('event.target.value : '+event.target.value);
            const keyMap = this.getService_Type;
            console.log('this.getService_Type : '+JSON.stringify(this.getService_Type));
            console.log(this.mapService_Topic);
            console.log('this.mapService_Topic[keyMap] : '+JSON.stringify(this.mapService_Topic[keyMap]));
            let listService_TopicOptions = [{label:'--None--', value:null}];
            for(let key in this.mapService_Topic[keyMap]) {
                console.log(key);
                console.log(this.mapService_Topic[keyMap][key]);
                listService_TopicOptions.push({
                    label : this.mapService_Topic[keyMap][key],
                    value: this.mapService_Topic[keyMap][key]
                })
            }
            console.log(listService_TopicOptions);
            this.listService_Topic = listService_TopicOptions;

            // for(let key in this.mapService_Topic[keyMap]) {
            //     console.log(key);
            //     console.log(this.mapService_Topic[keyMap][key]);
            //         this.listService_Topic.push({key: key, value: this.mapService_Topic[keyMap][key]});
            // }
            if(this.listService_Topic.length > 0){
                this.isEmptyService_Topic = false;
            }
        }
        console.log(this.listService_Topic);
    }
    Service_TopicChange(event) {
        this.listService_Subject = new Array();
        this.listService_Sub_Subject  = new Array();
        this.getService_Subject = '';
        this.getService_Sub_Subject = '';
        this.getSLA = '';
        this.isEmptyService_Subject = true;
        this.isEmptyService_Sub_Subject = true;
        const field = event.target.name;
        if (field === 'Service_TopicOption') {
            this.getService_Topic = event.target.value;
            const keyMap = this.getService_Type+'|'+this.getService_Topic;

            console.log('event.target.value : '+event.target.value);
            console.log('this.getService_Topic : '+JSON.stringify(this.getService_Topic));
            console.log(this.mapService_Subject);
            console.log('this.mapService_Subject[keyMap] : '+JSON.stringify(this.mapService_Subject[keyMap]));

            let listService_SubjectOptions = [{label:'--None--', value:null}];
            for(let key in this.mapService_Subject[keyMap]) {
                console.log('key');
                console.log(key);
                listService_SubjectOptions.push({
                    label : this.mapService_Subject[keyMap][key],
                    value: this.mapService_Subject[keyMap][key]
                })
            }
            console.log(listService_SubjectOptions);
            this.listService_Subject = listService_SubjectOptions;

            // for(let key in this.mapService_Subject[keyMap]) {
            //     console.log(key);
            //     console.log(this.mapService_Subject[keyMap][key]);
            //         this.listService_Subject.push({key: key, value: this.mapService_Subject[keyMap][key]});
            // }
            if(this.listService_Topic.length > 0){
                this.isEmptyService_Subject = false;
            }
        }
        console.log(this.listService_Subject);
    }
    Service_SubjectChange(event) {
        this.listService_Sub_Subject  = new Array();
        this.getService_Sub_Subject = '';
        this.getSLA = '';
        this.isEmptyService_Sub_Subject = true;
        const field = event.target.name;
        if (field === 'Service_SubjectOption') {
            this.getService_Subject = event.target.value;
            console.log('event.target.value : '+event.target.value);
            const keyMap = this.getService_Type+'|'+this.getService_Topic+'|'+this.getService_Subject;
            console.log('this.getService_Sub_Subject : '+JSON.stringify(this.getService_Sub_Subject));
            console.log(this.mapService_Sub_Subject);
            console.log('this.mapService_Sub_Subject[keyMap] : '+JSON.stringify(this.mapService_Sub_Subject[keyMap]));
            if(this.mapService_Sub_Subject[keyMap].length > 1){
                let listService_Sub_SubjectOptions = [{label:'--None--', value:null}];
                for(let key in this.mapService_Sub_Subject[keyMap]) {
                    console.log('key');
                    console.log(key);
                    listService_Sub_SubjectOptions.push({
                        label : this.mapService_Sub_Subject[keyMap][key],
                        value: this.mapService_Sub_Subject[keyMap][key]
                    })
                }
                console.log(listService_Sub_SubjectOptions);
                this.listService_Sub_Subject = listService_Sub_SubjectOptions;
                // for(let key in this.mapService_Sub_Subject[keyMap]) {
                //     console.log(key);
                //     console.log(this.mapService_Sub_Subject[keyMap][key]);
                //         this.listService_Sub_Subject.push({key: key, value: this.mapService_Sub_Subject[keyMap][key]});
                // }
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
                console.log(keyMapSLA);
                if(this.mapSLA[keyMapSLA].length > 0){
                    this.getSLA = this.mapSLA[keyMapSLA][0];
                }
            }
            
        }
        console.log(this.listService_Sub_Subject);
    }
    Service_Sub_SubjectChange(event) {
        const field = event.target.name;
        this.getSLA = '';
        if (field === 'Service_Sub_SubjectOption') {
            this.getService_Sub_Subject = event.target.value;
            const keyMapSLA = this.getService_Type+'|'+this.getService_Topic+'|'+this.getService_Subject+'|'+this.getService_Sub_Subject;
            console.log(keyMapSLA);
            console.log(this.mapSLA[keyMapSLA]);
            if(this.mapSLA[keyMapSLA].length > 0){
                this.getSLA = this.mapSLA[keyMapSLA][0];
            }
        }   
    }

    stampStatus(event){
        this.chooseStatus = event.target.value;
        console.log('Status : ',this.chooseStatus)
    }
    stampOrigin(event){
        this.chooseOrigin = event.target.value;
        console.log('Origin : ',this.chooseOrigin)
    }
    stampDivision(){
        let service_division = this.template.querySelector(`[data-id="service_division"]`);
        this.chooseDivision = service_division.value;
        console.log('สายงาน : ',this.chooseDivision)

        this.isEmpty = false;
        let dependValues = [];
        this.dependentValues = new Array();

        if(this.chooseDivision) {
            // if Selected country is none returns nothing
            if(this.chooseDivision === '--None--') {
                this.isEmpty = true;
                dependValues = [{label:'--None--', value:'--None--'}];
                this.chooseDivision = null;
                this.chooseSubDivision = null;
                return;
            }

            // filter the total dependent values based on selected country value 
            this.totalDependentValues.forEach(conValues => {
                if(conValues.validFor[0] === this.controlSubDivisionValues[this.chooseDivision]) {
                    dependValues.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            })

            this.lstSubDivision = dependValues;
        }
    }
    stampSubDivision(event){
        this.chooseSubDivision = event.target.value;
        console.log('Sub Division : ',this.chooseSubDivision)
    }

    test(){
        alert('TEST');
    }

    save(){
        let contact = this.template.querySelector(`[data-id="contact"]`);
        let source = this.template.querySelector(`[data-id="source"]`);
        let account = this.template.querySelector(`[data-id="account"]`);
        // let owner = this.template.querySelector(`[data-id="owner"]`);

        let type = this.template.querySelector(`[data-id="service_type"]`);
        let topic = this.template.querySelector(`[data-id="service_topic"]`);
        let subject = this.template.querySelector(`[data-id="service_subject"]`);
        let sub_subject = this.template.querySelector(`[data-id="service_sub_subject"]`);

        let description = this.template.querySelector(`[data-id="description"]`);
        // let status = this.template.querySelector(`[data-id="status"]`);
        // let division = this.template.querySelector(`[data-id="service_division"]`);
        // let subDivision = this.template.querySelector(`[data-id="service_subDivision"]`);
        // let origin = this.template.querySelector(`[data-id="service_origin"]`);

        console.log('recordId : ',this.recordId)
        console.log('contact',contact.value)
        console.log('source',source.value)
        console.log('account',account.value)
        console.log('type',type.value)
        console.log('topic',topic.value)
        console.log('subject',subject.value)
        console.log('sub_subject',sub_subject.value)
        console.log('status',this.chooseStatus)
        console.log('division',this.chooseDivision)
        console.log('subDivision',this.chooseSubDivision)
        console.log('origin',this.chooseOrigin)
        console.log('SLA : ',this.getSLA)
        
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
            console.log('save : ', result);
        })
        .catch(error => {
            this.error = error;
        });
    }

}