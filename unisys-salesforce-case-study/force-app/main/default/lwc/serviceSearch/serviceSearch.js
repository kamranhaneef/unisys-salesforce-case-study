import { LightningElement, track } from 'lwc';
import searchServices from '@salesforce/apex/ServiceSearchController.searchServices';

const COLUMNS = [
    { label: 'Nombre Cliente', fieldName: 'clientName', type: 'text' },
    { label: 'DNI Cliente', fieldName: 'clientDni', type: 'text' },
    { label: 'Nombre Servicio', fieldName: 'serviceName', type: 'text' },
    { label: 'Estado Servicio', fieldName: 'serviceStatus', type: 'text' }
];

export default class ServiceSearch extends LightningElement {
    @track clientName = '';
    @track serviceName = '';
    @track services = [];
    @track isLoading = false;
    columns = COLUMNS;

    handleClientChange(event) {
        this.clientName = event.target.value;
    }

    handleServiceChange(event) {
        this.serviceName = event.target.value;
    }

    handleSearch() {
        if (this.isLoading) return; // Prevent double clicks
        
        this.isLoading = true;

        searchServices({ clientName: this.clientName, serviceName: this.serviceName })
            .then(result => {
                this.services = [...result];
            })
            .catch(error => {
                // Ignore silent network aborts
                if (error && error.message !== 'Disconnected or Canceled') {
                    console.error('Search error:', error);
                }
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}