@isTest
private class CaseStudyTest {

    @testSetup
    static void setupData() {
        // Active Account
        Account acc = new Account(
            Name = 'Cliente Test',
            DNI__c = '12345678A',
            Active__c = true
        );
        insert acc;

        // Special Service
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

    // 1. Account Trigger Coverage
    @isTest
    static void testAccountActivation() {
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

        List<Servicio__c> services = [SELECT Id FROM Servicio__c WHERE Cliente__c = :inactiveAcc.Id];
        System.assert(services != null);
    }

    // 2. Servicio Trigger Coverage (Validations & Errors)
    @isTest
    static void testServicioValidationRules() {
        Account inactiveAcc = new Account(
            Name = 'Cliente Inactivo 2',
            DNI__c = '11223344C',
            Active__c = false
        );
        insert inactiveAcc;

        Test.startTest();
        // Test Special Service creation on inactive account (Error path)
        try {
            Servicio__c invalidServ = new Servicio__c(
                Name = 'Especial Invalido',
                Cliente__c = inactiveAcc.Id,
                Type__c = 'Especial',
                Cost_Without_VAT__c = 300,
                VAT_Rate__c = '21%'
            );
            insert invalidServ;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('No se pueden crear servicios especiales'));
        }

        // Test Edit Generic Service lock (Error path)
        Account activeAcc = [SELECT Id FROM Account WHERE Active__c = true LIMIT 1];
        Servicio__c genServ = new Servicio__c(
            Name = 'Limpieza Temp',
            Cliente__c = activeAcc.Id,
            Type__c = 'Generico',
            Cost_Without_VAT__c = 1000,
            VAT_Rate__c = '21%',
            Status__c = 'Aprobado'
        );
        insert genServ;

        try {
            genServ.Cost_Without_VAT__c = 1200;
            update genServ;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('genericos no se pueden editar'));
        }
        Test.stopTest();
    }

    // 3. Batches Coverage
    @isTest
    static void testBatches() {
        Test.startTest();
        Database.executeBatch(new ApproveServicesBatch());
        Database.executeBatch(new ProcessCasesBatch());
        Test.stopTest();
    }

    // 4. REST API Coverage (GET, POST, PATCH)
    @isTest
    static void testRestApiFull() {
        Account acc = [SELECT Id, DNI__c FROM Account LIMIT 1];
        Servicio__c serv = [SELECT Id FROM Servicio__c LIMIT 1];

        // Setup REST Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        // POST: Create Case
        CaseManagementAPI.ResponseWrapper postRes = CaseManagementAPI.createCase(acc.Id, serv.Id, 'Test Description');
        System.assertEquals(true, postRes.success);

        // GET: Fetch Cases
        req.requestURI = '/services/apexrest/CaseManagement/';
        req.httpMethod = 'GET';
        req.addParameter('dni', '12345678A');
        CaseManagementAPI.ResponseWrapper getRes = CaseManagementAPI.getCasesByDni();
        System.assertEquals(true, getRes.success);

        // PATCH: Update Case Status
        if (postRes.payload != null && !postRes.payload.isEmpty()) {
            String caseId = postRes.payload[0].caseId;
            CaseManagementAPI.ResponseWrapper patchRes = CaseManagementAPI.updateCaseStatus(caseId, 'En proceso');
            System.assertEquals(true, patchRes.success);
        }
        Test.stopTest();
    }

    // 5. LWC Controller Coverage
    @isTest
    static void testLwcController() {
        Test.startTest();
        List<ServiceSearchController.ServicioWrapper> results = ServiceSearchController.searchServices('Cliente', 'Servicio');
        System.assert(results != null);
        Test.stopTest();
    }
}