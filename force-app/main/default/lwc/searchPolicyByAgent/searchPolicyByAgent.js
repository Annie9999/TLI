import { LightningElement,track } from 'lwc';
import search from '@salesforce/apex/searchPolicyByAgentCtrl.search';

const data = [
    { id: 1, name: 'Billy Simonns', age: 40, email: 'billy@salesforce.com' },
    { id: 2, name: 'Kelsey Denesik', age: 35, email: 'kelsey@salesforce.com' },
    { id: 3, name: 'Kyle Ruecker', age: 50, email: 'kyle@salesforce.com' },
    {
        id: 4,
        name: 'Krystina Kerluke',
        age: 37,
        email: 'krystina@salesforce.com',
    },
];

const columns = [
    { label: '#', fieldName: '' },
    { label: 'ลำดับ', fieldName: 'No__c' },
    { label: 'กธ. ภายใต้การดูแล', fieldName: '' },
    { label: 'ชื่อ - นามสกุลผู้เอาประกัน', fieldName: 'NameInsured' },
    { label: 'หมายเลขบัตรประชาชน', fieldName: 'Citizen_ID__c' },
    { label: 'วัน เดือน ปีเกิด', fieldName: 'Birthdate__c' },
    { label: 'ระดับผู้เอาประกัน', fieldName: '' },
    { label: 'เพศ', fieldName: 'Gender__c' },
    // {
    //     label: 'Age',
    //     fieldName: 'age',
    //     type: 'number',
    //     sortable: true,
    //     cellAttributes: { alignment: 'left' },
    // },
    // { label: 'Email', fieldName: 'email', type: 'email' },
];

export default class SearchPolicyByAgent extends LightningElement {
    @track month = [
        {
            label: "มกราคม",
            value: "มกราคม"
        },
        {
            label: "กุมภาพันธ์",
            value: "กุมภาพันธ์"
        },
        {
            label: "มีนาคม",
            value: "มีนาคม"
        },
        {
            label: "เมษายน",
            value: "เมษายน"
        },
        {
            label: "พฤษภาคม",
            value: "พฤษภาคม"
        },
        {
            label: "มิถุนายน",
            value: "มิถุนายน"
        },
        {
            label: "กรกฎาคม",
            value: "กรกฎาคม"
        },
        {
            label: "สิงหาคม",
            value: "สิงหาคม"
        },
        {
            label: "กันยายน",
            value: "กันยายน"
        },
        {
            label: "ตุลาคม",
            value: "ตุลาคม"
        },
        {
            label: "พฤศจิกายน",
            value: "พฤศจิกายน"
        },
        {
            label: "ธันวาคม",
            value: "ธันวาคม"
        },
    ]

    @track data;
    @track data_temp = [
        {
            "Birthdate__c":String,
            "Gender__c":String,
            "Id":String,
            "Name":String,
            "NameInsured":String,
            "NameInsuredId":String,
            "Citizen_ID__c":String,
            "Insured__c":String,
            "No__c":String
        }
        // {
        //     Birthdate__c:String,
        //     Gender__c:String,
        //     Id:String,
        //     Name:String,
        //     NameInsured:String,
        //     NameInsuredId:String,
        //     Citizen_ID__c:String,
        //     Insured__c:String,
        //     No__c:String
        // }
    ];
    @track columns = columns;
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;

    keyword = '';

    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                return primer(x[field]);
            }
            : function(x) {
                return x[field];
            };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    constructor(){
        super();
        // this.search();
    }

    search(){
        var item = [];
        let inputName = this.template.querySelector(`[data-id="Name"]`);
        let inputInsuranceFirstName = this.template.querySelector(`[data-id="insuranceFirstName"]`);
        let inputInsuranceLastName = this.template.querySelector(`[data-id="insuranceLastName"]`);
        console.log('InputName.value : ',inputName.value);
        console.log('inputInsuranceFirstName.value : ',inputInsuranceFirstName.value);
        console.log('inputInsuranceLastName.value : ',inputInsuranceLastName.value);


        search({keyword: inputName.value, firstNameInsured: inputInsuranceFirstName.value, lastNameInsured: inputInsuranceLastName.value})
        .then(result => {
            var i;
            for (i = 0; i < result.length; i++) {
                // var formatData;
                console.log(result[i])
                if(result[i].Id !== undefined || result[i].Id !== 'undefined' || result[i].Id !== '')
                this.data_temp[i].Id = result[i].Id;
                if(result[i].Birthdate__c !== undefined || result[i].Birthdate__c !== 'undefined' || result[i].Birthdate__c !== '')
                this.data_temp[i].Birthdate__c = result[i].Birthdate__c;
                if(result[i].Gender__c !== undefined || result[i].Gender__c !== 'undefined' || result[i].Gender__c !== '')
                this.data_temp[i].Gender__c = result[i].Gender__c;
                if(result[i].Name !== undefined || result[i].Name !== 'undefined' || result[i].Name !== '')
                this.data_temp[i].Name = result[i].Name;
                if(result[i].NameInsuredId !== undefined || result[i].NameInsuredId !== 'undefined' || result[i].NameInsuredId !== '')
                this.data_temp[i].NameInsuredId = result[i].NameInsuredId;
                if(result[i].Citizen_ID__c !== undefined || result[i].Citizen_ID__c !== 'undefined' || result[i].Citizen_ID__c !== '')
                this.data_temp[i].Citizen_ID__c = result[i].Citizen_ID__c;
                if(result[i].Insured__c !== undefined || result[i].Insured__c !== 'undefined' || result[i].Insured__c !== '')
                this.data_temp[i].Insured__c = result[i].Insured__c;
                if(result[i].NameInsured.Name !== undefined || result[i].NameInsured.Name !== 'undefined' || result[i].NameInsured.Name !== '')
                this.data_temp[i].NameInsured = result[i].NameInsured.Name;
            }
            // var originalElement = this.data.srcElement || this.data.originalTarget;
            // this.data = originalElement;
            console.log('this.data_temp : ',this.data_temp);
            // const objUncovered = JSON.parse(JSON.stringify(this.data_tem));
            // console.log('objUncovered : ',objUncovered)
            // console.log('this.data_temp.originalTarget : ',this.data_temp.originalTarget);
            this.data = this.data_temp;
            console.log('result : ',result);
            console.log('this.data : ',this.data);
        })
        .catch(err => {
            console.log(err);
        })
    }
}