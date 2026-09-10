public with sharing class ServicioTriggerHandler {
    public static void handleBefore(List<Servicio__c> newServices, Map<Id, Servicio__c> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Servicio__c s : newServices) {
            if (s.Cliente__c != null) {
                accountIds.add(s.Cliente__c);
            }
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Active__c FROM Account WHERE Id IN :accountIds]
        );

        for (Servicio__c s : newServices) {
            Account parentAcc = accountMap.get(s.Cliente__c);

            // 1. Only enforce activation check on SPECIAL services
            if (s.Type__c == 'Especial' && (parentAcc == null || !parentAcc.Active__c)) {
                s.addError('No se pueden crear servicios especiales para clientes inactivos.');
            }

            // 2. Lock Generic Services against manual updates
            if (Trigger.isUpdate && oldMap != null && oldMap.containsKey(s.Id)) {
                Servicio__c oldService = oldMap.get(s.Id);
                if (oldService.Type__c == 'Generico') {
                    s.addError('Los servicios genéricos no se pueden editar.');
                }
            }
        }
    }
}