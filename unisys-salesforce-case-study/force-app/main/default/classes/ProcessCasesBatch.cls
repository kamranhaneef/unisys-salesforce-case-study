public class ProcessCasesBatch implements Database.Batchable<sObject>, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status 
            FROM Case 
            WHERE Status = 'Inicial'
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope) {
        for (Case c : scope) {
            c.Status = 'En proceso';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {}

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ProcessCasesBatch(), 200);
    }
}