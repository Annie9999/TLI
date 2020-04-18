import { LightningElement,track } from 'lwc';

export default class CustomEditCaseParentBenefit extends LightningElement {
    @track value = '';

    get options() {
        return [
            { label: 'มีบันทึก', value: 'yes' },
            { label: 'ไม่มีบันทึก', value: 'no' },
        ];
    }
}