public with sharing class ServiceSearchController {

    @AuraEnabled
    public static List<ServicioWrapper> searchServices(String clientName, String serviceName) {
        List<ServicioWrapper> results = new List<ServicioWrapper>();

        String clientPattern = String.isNotBlank(clientName) ? '%' + clientName.trim() + '%' : '%';
        String servicePattern = String.isNotBlank(serviceName) ? '%' + serviceName.trim() + '%' : '%';

        List<Servicio__c> services = [
            SELECT Id, Name, Status__c, Cliente__r.Name, Cliente__r.DNI__c
            FROM Servicio__c
            WHERE Cliente__r.Name LIKE :clientPattern
              AND Name LIKE :servicePattern
            WITH USER_MODE
            LIMIT 100
        ];

        for (Servicio__c s : services) {
            ServicioWrapper wrap = new ServicioWrapper();
            wrap.serviceId = s.Id;
            wrap.clientName = s.Cliente__r != null ? s.Cliente__r.Name : '';
            wrap.clientDni = s.Cliente__r != null ? s.Cliente__r.DNI__c : '';
            wrap.serviceName = s.Name;
            wrap.serviceStatus = s.Status__c;
            results.add(wrap);
        }

        return results;
    }

    public class ServicioWrapper {
        @AuraEnabled public String serviceId;
        @AuraEnabled public String clientName;
        @AuraEnabled public String clientDni;
        @AuraEnabled public String serviceName;
        @AuraEnabled public String serviceStatus;
    }
}