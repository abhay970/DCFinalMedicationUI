import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccessToken2 from '@salesforce/apex/OAuthExample2.getAccessToken2';
export default class PatientsDetails1 extends LightningElement {
    @track nameValue = '';
    @track providerData = [];
    showMain = true;
    showResult = false;
    inputDataForApex = {};
    handleName(event) {
        this.nameValue = event.target.value;
        this.inputDataForApex.Name = this.nameValue;
        console.log('Name:', this.nameValue);
    }
    handleSearchDeB() {
        console.log('handleSearchDeB - start',this.nameValue);
        getAccessToken2({input:this.nameValue})
            .then(result => {
                console.log('handleSearchDeB result:', result);
                console.log('handleSearchDeB result>>>>>>:', JSON.stringify(result));
                this.providerData = result;
                this.showMain = false;
                this.showResult = true;
            })
            .catch(error => {
                console.error('handleSearchDeB error:', error);
                this.showToast('Invalid Patient ID', 'Please enter a correct Patient ID.', 'error');
                this.showMain = true;
                this.showResult = false;
            });
    }

    handleBackDB() {
        this.showMain = true;
        this.showResult = false;
        console.log('Back to search page. showMain:', this.showMain, ', showResult:', this.showResult);
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}
