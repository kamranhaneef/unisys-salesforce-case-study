public with sharing class ServiceSearchController {
    @AuraEnabled(cacheable=true)
    public static List<ServicioWrapper> searchServices(String clientName, String serviceName) {
        String query = 'SELECT Id, Name, Status__c, Cliente__r.Name, Cliente__r.DNI__c ' +
                       'FROM Servicio__c WHERE Id != NULL';
        
        if (String.isNotBlank(clientName)) {
            query += ' AND Cliente__r.Name LIKE :clientKey';
        }
        if (String.isNotBlank(serviceName)) {
            query += ' AND Name LIKE :serviceKey';
        }

        String clientKey = '%' + clientName + '%';
        String serviceKey = '%' + serviceName + '%';

        List<Servicio__c> results = Database.query(query);
        List<ServicioWrapper> wrappers = new List<ServicioWrapper>();
        
        for (Servicio__c s : results) {
            wrappers.add(new ServicioWrapper(s));
        }
        return wrappers;
    }

    public class ServicioWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String clientName;
        @AuraEnabled public String clientDni;
        @AuraEnabled public String serviceName;
        @AuraEnabled public String status;

        public ServicioWrapper(Servicio__c s) {
            this.id = s.Id;
            this.clientName = s.Cliente__r != null ? s.Cliente__r.Name : '';
            this.clientDni = s.Cliente__r != null ? s.Cliente__r.DNI__c : '';
            this.serviceName = s.Name;
            this.status = s.Status__c;
        }
    }
}