import { LightningElement, api, track } from 'lwc';

export default class MedicationChild extends LightningElement {
    @api item = {};
    @api label; // Expecting the label to be passed from parent

    @track showProviderSearchResultCardDB = false;
    @track PernalDetail = false;
    @track specialties = false;
    @track insurancesDetails = false;
    @track expandedId = null;

    handleShow() {
        this.showProviderSearchResultCardDB = !this.showProviderSearchResultCardDB;
    }

    handleToggleDetail(event) {
        const id = event.currentTarget.dataset.id;
        this.expandedId = this.expandedId === id ? null : id;
    }

    handleShowOn() {
        this.PernalDetail = !this.PernalDetail;
    }
    
    handleShowTw() {
        this.specialties = !this.specialties;
    }

    handleShowThr() {
        this.insurancesDetails = !this.insurancesDetails;
    }
}
