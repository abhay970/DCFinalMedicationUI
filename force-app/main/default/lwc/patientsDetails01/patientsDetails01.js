import { LightningElement, api, track } from 'lwc';
import getEpicPatientId from '@salesforce/apex/EpicPatientIdController.getEpicPatientId';
import getAccessToken2 from '@salesforce/apex/OAuthExample2.getAccessToken2';

export default class PatientsDetails01 extends LightningElement {
    @api recordId;
    @track providerData = [];
    @track showResult = false;

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        getEpicPatientId({ patientId: this.recordId })
            .then(result => {
                if (result) {
                    return getAccessToken2({ input: result });
                } else {
                    throw new Error('No Epic Patient ID found.');
                }
            })
            .then(result => {
                console.log('Data:', result);
                this.providerData = result;
                this.showResult = true; // Show results after data is loaded
            })
            .catch(error => {
                console.error('Error:', error);
                this.showResult = false; // Hide results on error
            });
    }
}
