import ballerina/http;

// Dummy dataset of passwords (in real scenarios, this would be a database or more secure storage)
string[] dummyPasswords = ["password123", "letmein", "securepassword", "12345678"];

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
    resource function post checkPassword(http:Caller caller, http:Request req) returns error? {
        // Extract password from request payload
        json payload = check req.getJsonPayload();
        json password = check payload.password;
        json responseJson;

        if (password.toString() == "") {
            responseJson = {  "isValid": false, "message": "Password is empty." };
        } else {
            // Validate the password
            boolean isFound = findPassword(password.toString());

            // Prepare response based on validation result
            if (!isFound) {
                responseJson = { "isValid": true, "message": "Password accepted." };
            } else {
                responseJson = { "isValid": false, "message": "Password found in password directory. Please try a different password." };
            }
        }

        // Send response
        var response = caller->respond(responseJson);
        check response;
    }
}
