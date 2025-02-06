import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerinax/salesforce;
import ballerina/http;

// Create Salesforce client configuration by reading from environment.
configurable string salesforceAppClientId = ?;
configurable string salesforceAppClientSecret = ?;
configurable string salesforceAppRefreshToken = ?;
configurable string salesforceAppRefreshUrl = ?;
configurable string salesforceAppBaseUrl = ?;

// Using direct-token config for client configuration
salesforce:ConnectionConfig sfConfig = {
    baseUrl: salesforceAppBaseUrl,
    auth: {
        clientId: salesforceAppClientId,
        clientSecret: salesforceAppClientSecret,
        refreshToken: salesforceAppRefreshToken,
        refreshUrl: salesforceAppRefreshUrl
    }
};

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

service asgardeo:RegistrationService on webhookListener {

    remote function onAddUser(asgardeo:AddUserEvent event ) returns error? {

        salesforce:Client baseClient = check new (sfConfig);

        log:printInfo(event.toJsonString());
        
        json responseData = event.eventData.toJson();

        map<json> mj = <map<json>> responseData;
        map<json> userClaims = <map<json>> mj.get("claims");
        record {} newLeadRecord = {};
        
        string lastName = <string>userClaims["http://wso2.org/claims/lastname"];
        string firstName = <string>userClaims["http://wso2.org/claims/givenname"];
        string email = <string>userClaims["http://wso2.org/claims/emailaddress"];

        string query = string `SELECT Id FROM Lead WHERE Email = '${lastName}' LIMIT 1`;

        stream<record {| anydata...; |}, error?>|error masterLeadResult = check baseClient->query(query);

        if masterLeadResult is error {
            log:printInfo("Error querying master lead: ", masterLeadResult);
            return;
        }

        stream<record {| anydata...; |}, error?> masterLeadStream = masterLeadResult;

        error? e;
        string masterLeadId = "";

        record {| anydata...; |}? | error leadRecord = check masterLeadStream.next();

        if leadRecord is record {| anydata...; |} {
            if leadRecord.hasKey("Id") {
                masterLeadId = leadRecord["Id"].toString();
                log:printInfo("Master Lead found with ID: " + masterLeadId);
            }
        } else if leadRecord is error {
            log:printInfo("Error while retrieving lead records: ");
            return;
        }

        // Close the stream
        e = masterLeadStream.close();
        if e is error {
            log:printInfo("Error closing stream: " + e.toString());
        }

        // If a Master Lead was found, create a new lead and link it
        if masterLeadId != "" {
            newLeadRecord = {
                "Company": "WSO2",
                "Email": email,
                "FirstName": firstName,
                "LastName": lastName,
                "Master_Lead__c": masterLeadId
            };
                salesforce:CreationResponse|error res = baseClient->create("Lead", newLeadRecord);

            if res is salesforce:CreationResponse {
            log:printInfo("Lead Created Successfully. Lead ID : " + res.id + " and linked to Master Lead ID : " + masterLeadId);
            } else {
                log:printError(msg = res.message());
            }
        } else {
            log:printInfo("No Master Lead found.");
            newLeadRecord = {
                    "Company": "WSO2",
                    "Email": email,
                    "FirstName": firstName,
                    "LastName": lastName
                };
                salesforce:CreationResponse|error res = baseClient->create("Lead", newLeadRecord);
                if res is salesforce:CreationResponse {
                    log:printInfo("Lead Created Successfully. Lead ID : " + res.id);
                } else {
                    log:printError(msg = res.message());
                }
        }
    }

    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }

    remote function onAcceptUserInvite(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }
}

service /ignore on httpListener {}
