import ballerina/http;

// Dummy dataset of passwords (in real scenarios, this would be a database or more secure storage)
string[] dummyPasswords = ["password123", "letmein", "securepassword", "12345678", "Hasintha@123"];

// Function to check if the password is valid
function findPassword(string password) returns boolean {
    foreach var dummyPwd in dummyPasswords {
        if (password == dummyPwd) {
            return true;
        }
    }
    return false;
}

// HTTP service endpoint
service /passwordService on new http:Listener(8080) {

    // Resource to handle POST requests to validate password
    resource function post checkPassword(@http:Payload PasswordEntry passwordEntry) returns ValidityResponse {
        ValidityResponse responseJson;

        if (passwordEntry.password == "") {
            responseJson = {  "isValid": false, "message": "Password is empty." };
        } else {
            // Validate the password
            boolean isFound = findPassword(passwordEntry.password);

            // Prepare response based on validation result
            if (!isFound) {
                responseJson = { "isValid": true, "message": "Password accepted." };
            } else {
                responseJson = { "isValid": false, "message": "Password found in password directory. Please try a different password." };
            }
        }
        // Send response
        return responseJson;
    }
}

public type PasswordEntry record {|
    string password;
|};

public type ValidityResponse record {|
    boolean isValid;
    string message;
|};
