
import { LightningElement, api, track } from 'lwc';

export default class PatientsDetailsChild01 extends LightningElement {
    @api item = {};
    @track PernalDetail = false; 
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

    handleShowOn() {
        this.PernalDetail = !this.PernalDetail;
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
