import { LightningElement,track, api } from 'lwc';
import search from '@salesforce/apex/searchPolicyByAgentCtrl.search';
import { RecordFieldDataType } from 'lightning/uiRecordApi';

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
    { label: 'เลขที่กรมธรรม์', fieldName: 'policy_url' , type: 'url', target: '_blank' , typeAttributes: {label: { fieldName: 'policy_name' }}},
    { label: 'ชื่อ - นามสกุลผู้เอาประกัน', fieldName: 'insured_url' , type: 'url', target: '_blank' , typeAttributes: {label: { fieldName: 'insured_name' }}},
    // {
    //     label: 'ลำดับ',
    //     fieldName: 'no',
    //     type: 'number',
    //     sortable: true,
    //     cellAttributes: { alignment: 'left' },
    // },
    // { label: 'เลขที่กรมธรรม์', fieldName: 'policy_name' },
    // { label: 'ชื่อ - นามสกุลผู้เอาประกัน', fieldName: 'insured_name' },
    // { label: 'หมายเลขบัตรประชาชน', fieldName: 'citizenId' },
    { label: 'วัน เดือน ปีเกิด', fieldName: 'birthdate' },
    { label: 'แบบประกัน', fieldName: 'plan_name' },
    { label: 'สถานะกรมธรรม์', fieldName: 'policy_payment_status' },
    { label: 'วันที่เริ่มสัญญา', fieldName: 'EffectiveDate' },
    // { label: 'เพศ', fieldName: 'gender' },
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
    @api recordId;

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

    @track data = [];
    @track columns = columns;
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;

    @track isData = true;

    // @track loadMoreStatus;
    // @api totalNumberOfRows;

    // inputName = this.template.querySelector(`[data-id="Name"]`);
    // inputInsuranceFirstName = this.template.querySelector(`[data-id="insuranceFirstName"]`);
    // inputInsuranceLastName = this.template.querySelector(`[data-id="insuranceLastName"]`);

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

    search(){
        console.log('recordId : ',this.recordId)
        let inputName = this.template.querySelector(`[data-id="Name"]`);
        let inputInsuranceFirstName = this.template.querySelector(`[data-id="insuranceFirstName"]`);
        let inputInsuranceLastName = this.template.querySelector(`[data-id="insuranceLastName"]`);
        console.log('InputName.value : ',inputName.value);
        console.log('inputInsuranceFirstName.value : ',inputInsuranceFirstName.value);
        console.log('inputInsuranceLastName.value : ',inputInsuranceLastName.value);


        search({policyId: this.recordId ,keyword: inputName.value, firstNameInsured: inputInsuranceFirstName.value, lastNameInsured: inputInsuranceLastName.value})
        .then(result => {
            console.log('result : ',result);
            if(result.length > 0){
                this.isData = true;
                this.data = result;
            }
            else{
                this.data = [];
                this.isData = false;
            }
        })
        .catch(err => {
            console.log(err);
        })
    }

    clear(){
        let inputName = this.template.querySelector(`[data-id="Name"]`);
        let inputInsuranceFirstName = this.template.querySelector(`[data-id="insuranceFirstName"]`);
        let inputInsuranceLastName = this.template.querySelector(`[data-id="insuranceLastName"]`);

        inputName.value = '';
        inputInsuranceFirstName.value = '';
        inputInsuranceLastName.value = '';
        this.data = [];
        this.isData = true;
    }

    // loadMoreData(event) {
    //     //Display a spinner to signal that data is being loaded
    //     event.target.isLoading = true;
    //     //Display "Loading" when more data is being loaded
    //     this.loadMoreStatus = 'Loading';
    //     fetchData(10)
    //         .then((data) => {
    //             console.log('data : ',data)
    //             if (data.length >= this.totalNumberOfRows) {
    //                 console.log('if : ',this.totalNumberOfRows)
    //                 event.target.enableInfiniteLoading = false;
    //                 this.loadMoreStatus = 'No more data to load';
    //             } 
    //             else {
    //                 console.log('else : ',this.totalNumberOfRows)
    //                 const currentData = this.data;
    //                 //Appends new data to the end of the table
    //                 const newData = currentData.concat(data);
    //                 this.data = newData;
    //                 this.loadMoreStatus = '';
    //             }
    //             event.target.isLoading = false;
    //         })
    //         .catch(err => {
    //             console.log('data table error :> ', err);
    //         });
    // }
}