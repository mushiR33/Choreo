import ballerina/http;
import ballerina/io;
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
    {userid: "user2", email: "user2@example.com", passwordHash: "e86f7fc56ed572b80d5a6b9e00c24e842018d0ef92b43e253f1065aa215e57f0"},
    {userid: "user3", email: "user3@example.com", passwordHash: "e86f7ce216e2fd396621a81fc3159db42a38282e806658340ca1b39d16e86282"}
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
            io:println(sendPasswordHashesResult.cause());
        } else {
             map<json> countsOfPasswords = check sendPasswordHashesResult.ensureType();
             json countJson = countsOfPasswords[user.passwordHash];
             int reusedCount = check countJson.count;
             if (reusedCount > allowedReusedCount) {
                io:println("*****Send Email*****");
                string amEmailTemplate = check io:fileReadString(EMAIL_TEMPLATE_FILE_PATH);
                // Send the email
                string _ = check emailClient->sendEmail(user.email, emailSubject, "Your password has been compromised! Please make sure to reset it before the next login!");
                io:println("Successfully sent the email.");
             }
        }
    }
}