import ballerina/http;
import ballerina/log;
import wso2/choreo.sendemail;

type PasswordHash record {
    string hash;
};

// Define your password hashes here
PasswordHash[] passwordHashes = [
    {hash: "hash1"},
    {hash: "hash2"},
    {hash: "hash3"}
];

type User record {
    string userid;
    string email;
    string passwordHash;
};

// Define your users here
User[] users = [
    {userid: "user1", email: "mushthaq33@gmail.com", passwordHash: "e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7"},
    {userid: "user2", email: "hasintha@wso2.com", passwordHash: "3e7c19576488862816f13b512cacf3e4ba97dd97243ea0bd6a2ad1642d86ba72"},
    {userid: "user3", email: "vihanga@wso2.com", passwordHash: "8e6d5067a6cc645877b5cd39a41027981cbc8bde52af816b0b300a085958c252"}
];

http:Client passwordHashApiClient = check new ("https://api.spycloud.io");
// Create a new email client
sendemail:Client emailClient = check new ();
const string EMAIL_TEMPLATE_FILE_PATH = "password-reset.html";

// Define the path parameter
string pathParam = "somePathParam";
string emailSubject = "[URGENT] Reset Password";
int allowedReusedCount = 100;

function sendPasswordHashes(string hashValue) returns json|error? {

    string requestUrl = "/nist-password-v2/check/hashes/" + hashValue + "?type=sha256";

    // Set headers
    map<string> headers = {
        "Accept": "application/json",
        "x-api-key": "dY5M73VPgW1fz5gY5GiRP4s2roZEOz8G1Gx8WloH"
    };

    http:Response response = check passwordHashApiClient->get(requestUrl, headers);
    return response.getJsonPayload();
}

public function main() returns error? {
    foreach var user in users {
        string firstFiveChars = user.passwordHash.substring(0, 5);
        json|error? sendPasswordHashesResult = sendPasswordHashes(firstFiveChars);
        if sendPasswordHashesResult is error {
            log:printError("Error in response", sendPasswordHashesResult);
        } else {
            json|error? errMessage = sendPasswordHashesResult.message;
            if sendPasswordHashesResult is json && errMessage is json {
                log:printError("Error in response: " + errMessage.toString());
            } else {
                map<json>|error? countsOfPasswords = check sendPasswordHashesResult.ensureType();
                if countsOfPasswords is map<json> {
                    json countJson = countsOfPasswords[user.passwordHash];
                    int reusedCount = check countJson.count;
                    if (reusedCount > allowedReusedCount) {
                        log:printInfo("*****Send Email*****");
                        // Send the email
                        string _ = check emailClient->sendEmail(user.email, emailSubject, "Your password has been compromised! Please make sure to reset it before the next login!");
                        log:printInfo("Successfully sent the email.");
                    }
                } else {
                    log:printError("Error in response: ", countsOfPasswords);
                }
            }
        }
    }
}