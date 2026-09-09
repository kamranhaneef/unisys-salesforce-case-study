@RestResource(urlMapping='/CaseManagement/*')
global with sharing class CaseManagementAPI {

    // 1. GET: Retrieve list of Cases by DNI
    @HttpGet
    global static ResponseWrapper getCasesByDni() {
        RestRequest req = RestContext.request;
        String dni = req.params.get('dni');
        String serviceName = req.params.get('serviceName');
        String caseNumber = req.params.get('caseNumber');

        ResponseWrapper response = new ResponseWrapper();

        if (String.isBlank(dni)) {
            response.success = false;
            response.errorMessage = 'El DNI es obligatorio.';
            return response;
        }

        try {
            String query = 'SELECT Id, CaseNumber, Status, Description, Cliente__c, Cliente__r.Name, Cliente__r.DNI__c, ' +
                           'Servicio__c, Servicio__r.Name, Servicio__r.Cost_Without_VAT__c ' +
                           'FROM Case WHERE Cliente__r.DNI__c = :dni';

            if (String.isNotBlank(serviceName)) query += ' AND Servicio__r.Name = :serviceName';
            if (String.isNotBlank(caseNumber)) query += ' AND CaseNumber = :caseNumber';

            List<Case> cases = Database.query(query);
            response.payload = buildPayload(cases);
            response.success = true;
        } catch (Exception e) {
            response.success = false;
            response.errorMessage = e.getMessage();
        }

        return response;
    }

    // 2. POST: Create new Case
    @HttpPost
    global static ResponseWrapper createCase(String accountId, String serviceId, String description) {
        ResponseWrapper response = new ResponseWrapper();

        if (String.isBlank(accountId) || String.isBlank(serviceId) || String.isBlank(description)) {
            response.success = false;
            response.errorMessage = 'Los parámetros accountId, serviceId y description son obligatorios.';
            return response;
        }

        try {
            // Validate that service belongs to client
            List<Servicio__c> validServices = [
                SELECT Id FROM Servicio__c WHERE Id = :serviceId AND Cliente__c = :accountId
            ];

            if (validServices.isEmpty()) {
                response.success = false;
                response.errorMessage = 'El servicio especificado no pertenece al cliente indicado.';
                return response;
            }

            Case newCase = new Case(
                Cliente__c = accountId,
                Servicio__c = serviceId,
                Description = description,
                Status = 'Inicial',
                Type = 'Incidencia Servicios'
            );
            insert newCase;

            List<Case> insertedCase = [
                SELECT Id, CaseNumber, Status, Description, Cliente__c, Cliente__r.Name, Cliente__r.DNI__c,
                       Servicio__c, Servicio__r.Name, Servicio__r.Cost_Without_VAT__c 
                FROM Case WHERE Id = :newCase.Id
            ];

            response.payload = buildPayload(insertedCase);
            response.success = true;
        } catch (Exception e) {
            response.success = false;
            response.errorMessage = e.getMessage();
        }

        return response;
    }

    // 3. PATCH: Update Case Status
    @HttpPatch
    global static ResponseWrapper updateCaseStatus(String caseId, String status) {
        ResponseWrapper response = new ResponseWrapper();

        try {
            Case c = new Case(Id = caseId, Status = status);
            update c;

            List<Case> updatedCase = [
                SELECT Id, CaseNumber, Status, Description, Cliente__c, Cliente__r.Name, Cliente__r.DNI__c,
                       Servicio__c, Servicio__r.Name, Servicio__r.Cost_Without_VAT__c 
                FROM Case WHERE Id = :caseId
            ];

            response.payload = buildPayload(updatedCase);
            response.success = true;
        } catch (Exception e) {
            response.success = false;
            response.errorMessage = e.getMessage();
        }

        return response;
    }

    // Helper Payload Builders
    private static List<CaseDTO> buildPayload(List<Case> cases) {
        List<CaseDTO> dtos = new List<CaseDTO>();
        for (Case c : cases) {
            CaseDTO dto = new CaseDTO();
            dto.clientId = c.Cliente__c;
            dto.clientName = c.Cliente__r != null ? c.Cliente__r.Name : null;
            dto.clientDni = c.Cliente__r != null ? c.Cliente__r.DNI__c : null;
            dto.serviceId = c.Servicio__c;
            dto.serviceName = c.Servicio__r != null ? c.Servicio__r.Name : null;
            dto.serviceCostWithoutVat = c.Servicio__r != null ? c.Servicio__r.Cost_Without_VAT__c : null;
            dto.caseId = c.Id;
            dto.caseNumber = c.CaseNumber;
            dto.status = c.Status;
            dto.description = c.Description;
            dtos.add(dto);
        }
        return dtos;
    }

    global class ResponseWrapper {
        global Boolean success;
        global String errorMessage;
        global List<CaseDTO> payload;
    }

    global class CaseDTO {
        global String clientId;
        global String clientName;
        global String clientDni;
        global String serviceId;
        global String serviceName;
        global Decimal serviceCostWithoutVat;
        global String caseId;
        global String caseNumber;
        global String status;
        global String description;
    }
}