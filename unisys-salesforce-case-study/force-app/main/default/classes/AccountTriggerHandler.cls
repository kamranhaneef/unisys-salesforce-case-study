public with sharing class AccountTriggerHandler {
    public static void handleAfterUpdate(List<Account> newAccounts, Map<Id, Account> oldMap) {
        List<Servicio__c> servicesToInsert = new List<Servicio__c>();
        
        for (Account acc : newAccounts) {
            Account oldAcc = oldMap.get(acc.Id);
            // Auto-create standard services when Account is activated
            if (acc.Active__c && !oldAcc.Active__c) {
                servicesToInsert.add(createGenericService(acc.Id, 'Limpieza', 1000));
                servicesToInsert.add(createGenericService(acc.Id, 'Mantenimiento', 800));
                servicesToInsert.add(createGenericService(acc.Id, 'Seguridad', 1500));
            }
        }
        
        if (!servicesToInsert.isEmpty()) {
            insert servicesToInsert;
        }
    }

    private static Servicio__c createGenericService(Id accountId, String serviceName, Decimal cost) {
        return new Servicio__c(
            Name = serviceName,
            Cliente__c = accountId,
            Type__c = 'Generico',
            Cost_Without_VAT__c = cost,
            VAT_Rate__c = '21%',
            Status__c = 'Aprobado'
        );
    }
}