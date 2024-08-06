import { LightningElement, api, track } from 'lwc';

export default class PatientsDetailsChild1 extends LightningElement {
    @api item = {};
    @track showProviderSearchResultCardDB = false;
    @track PernalDetail = false;
    @track specialties = false;
    @track insurancesDetails = false;
    @track currentPage = 1;
    @track recordsPerPage = 5;

    get totalPages() {
        return Math.ceil(this.item.medicationRequest.length / this.recordsPerPage);
    }

    get paginatedRequests() {
        const start = (this.currentPage - 1) * this.recordsPerPage;
        const end = start + this.recordsPerPage;
        return this.item.medicationRequest.slice(start, end);
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    get practitionerPage() {
        return this.currentPage;
    }

    get totalPractitionerPages() {
        return this.totalPages;
    }

    getLabelForItem(index) {
        return `Medication Request ${((this.currentPage - 1) * this.recordsPerPage) + index + 1}`;
    }

    get paginatedRequestLabels() {
        return this.paginatedRequests.map((item, index) => ({
            ...item,
            label: this.getLabelForItem(index)
        }));
    }

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

    prevPagePractitioner() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    nextPagePractitioner() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }
}
