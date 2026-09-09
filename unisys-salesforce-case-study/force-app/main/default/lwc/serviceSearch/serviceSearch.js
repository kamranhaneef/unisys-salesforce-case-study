import { LightningElement, track } from 'lwc';
import searchServices from '@salesforce/apex/ServiceSearchController.searchServices';

const COLUMNS = [
    { label: 'Nombre Cliente', fieldName: 'clientName' },
    { label: 'DNI Cliente', fieldName: 'clientDni' },
    { label: 'Nombre Servicio', fieldName: 'serviceName' },
    { label: 'Estado Servicio', fieldName: 'status' }
];

export default class ServiceSearch extends LightningElement {
    @track clientName = '';
    @track serviceName = '';
    @track services = [];
    columns = COLUMNS;

    handleClientChange(e) { this.clientName = e.target.value; }
    handleServiceChange(e) { this.serviceName = e.target.value; }

    handleSearch() {
        searchServices({ clientName: this.clientName, serviceName: this.serviceName })
            .then(result => { this.services = result; })
            .catch(error => { console.error(error); });
    }
}