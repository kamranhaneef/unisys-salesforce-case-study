@isTest
private class CaseStudyTest {

    @testSetup
    static void setupData() {
        // Create Active Account
        Account acc = new Account(
            Name = 'Cliente Test',
            DNI__c = '12345678A',
            Active__c = true
        );
        insert acc;

        // Create Special Service
        Servicio__c specServ = new Servicio__c(
            Name = 'Servicio Especial Test',
            Cliente__c = acc.Id,
            Type__c = 'Especial',
            Cost_Without_VAT__c = 500,
            VAT_Rate__c = '21%',
            Status__c = 'Pendiente de aprobación'
        );
        insert specServ;
    }

    @isTest
    static void testAccountActivationAndServiceCreation() {
        Account inactiveAcc = new Account(
            Name = 'Cliente Inactivo',
            DNI__c = '87654321B',
            Active__c = false
        );
        insert inactiveAcc;

        Test.startTest();
        inactiveAcc.Active__c = true;
        update inactiveAcc;
        Test.stopTest();

        List<Servicio__c> services = [SELECT Id, Name FROM Servicio__c WHERE Cliente__c = :inactiveAcc.Id];
        System.assertEquals(3, services.size(), 'Three standard services should be created automatically.');
    }

    @isTest
    static void testApproveServicesBatch() {
        Test.startTest();
        Database.executeBatch(new ApproveServicesBatch());
        Test.stopTest();

        Servicio__c service = [SELECT Status__c FROM Servicio__c WHERE Type__c = 'Especial' LIMIT 1];
        System.assertEquals('Aprobado', service.Status__c, 'Pending service should be updated to Aprobado.');
    }

    @isTest
    static void testRestApiGetCases() {
        Account acc = [SELECT Id, DNI__c FROM Account LIMIT 1];
        Servicio__c serv = [SELECT Id FROM Servicio__c LIMIT 1];

        Case c = new Case(
            Cliente__c = acc.Id,
            Servicio__c = serv.Id,
            Description = 'Test Incident',
            Status = 'Inicial',
            Type = 'Incidencia Servicios'
        );
        insert c;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CaseManagement/';
        req.httpMethod = 'GET';
        req.addParameter('dni', '12345678A');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CaseManagementAPI.ResponseWrapper response = CaseManagementAPI.getCasesByDni();
        Test.stopTest();

        System.assertEquals(true, response.success);
        System.assertEquals(1, response.payload.size());
    }
}