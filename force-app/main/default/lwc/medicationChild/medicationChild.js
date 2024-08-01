import { LightningElement, api, track } from 'lwc';

export default class MedicationChild extends LightningElement {
    @api item = {};
    @track showProviderSearchResultCardDB = false;
    @track PernalDetail = false;
    @track specialties = false;
    @track insurancesDetails = false;
    @track expandedId = null; // Track the currently expanded ID

    handleShow() {
        this.showProviderSearchResultCardDB = !this.showProviderSearchResultCardDB;
    }

    handleToggleDetail(event) {
        const id = event.currentTarget.dataset.id; // Get the ID from the clicked element
        if (this.expandedId === id) {
            this.expandedId = null; // Collapse if the same ID is clicked
        } else {
            this.expandedId = id; // Expand the new ID
        }
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