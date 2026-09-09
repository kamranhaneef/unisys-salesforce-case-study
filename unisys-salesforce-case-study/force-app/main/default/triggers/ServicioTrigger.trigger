trigger ServicioTrigger on Servicio__c (before insert, before update) {
    if (Trigger.isBefore) {
        ServicioTriggerHandler.handleBefore(Trigger.new, Trigger.oldMap);
    }
}