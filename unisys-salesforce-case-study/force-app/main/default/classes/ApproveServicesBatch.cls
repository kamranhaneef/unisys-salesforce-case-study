public class ApproveServicesBatch implements Database.Batchable<sObject>, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status__c 
            FROM Servicio__c 
            WHERE Status__c = 'Pendiente de aprobación' 
              AND Cliente__r.Active__c = TRUE
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Servicio__c> scope) {
        for (Servicio__c s : scope) {
            s.Status__c = 'Aprobado';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {}

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ApproveServicesBatch(), 200);
    }
}