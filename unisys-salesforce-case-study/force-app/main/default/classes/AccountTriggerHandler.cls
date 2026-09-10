public with sharing class AccountTriggerHandler {
    public static void handleAfterUpdate(List<Account> newAccounts, Map<Id, Account> oldMap) {
        List<Servicio__c> servicesToInsert = new List<Servicio__c>();
        
        for (Account acc : newAccounts) {
            Account oldAcc = oldMap != null ? oldMap.get(acc.Id) : null;
            
            Boolean wasInactive = (oldAcc == null || oldAcc.Active__c == false);
            Boolean isNowActive = (acc.Active__c == true);

            if (isNowActive && wasInactive) {
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