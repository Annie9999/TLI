import { LightningElement,track } from 'lwc';

const columns = [
    { label: 'ลำดับ', fieldName: 'no' },
    { label: 'หัวข้อ', fieldName: 'topic', type: 'text' },
    { label: 'เรื่อง', fieldName: 'subject', type: 'text' },
    { label: 'เรื่องย่อย', fieldName: 'sub_subject', type: 'text' },
    { label: 'ผู้ให้บริการ', fieldName: 'provider', type: 'text' },
];

export default class CustomEditCaseParentDetail extends LightningElement {

    @track data = [
        {
            no: 1, topic: 'การชำระเบี้ยประกัน', subject: 'จำนวนเบี้ยประกันที่ต้องชำระ',sub_subject: 'เรื่องย่อย',provider: 'สุภาวรรณ์ นินวิบูลย์'
        }
    ];
    @track columns = columns;

    // async connectedCallback() {
    //     const data = await fetchDataHelper({ amountOfRecords: 100 });
    //     this.data = data;
    // }
}