import { LightningElement, api  } from 'lwc';

export default class CustomNewChildRecordListDetail extends LightningElement {
    @api index;
    get position() {
        return this.index + 1;
    }

}