import ballerina/http;
import ballerina/io;
import ballerina/uuid;

service / on new http:Listener(8090) {
    resource function post processPayload(@http:Payload json jsonMsg) returns http:Created|http:BadRequest|error? {
        //xml? xmlMsg = check xmldata:fromJson(jsonMsg);
        // Writes the given JSON to a file.
        // Generates a UUID of type 1 as a string.
        string uuid1String = uuid:createType1AsString();
        string jsonFilePath = "./files/" + uuid1String + ".json";
        check io:fileWriteJson(jsonFilePath, jsonMsg);
        //json readJson = check io:fileReadJson(jsonFilePath);
        //io:println(readJson);
        return <http:Created>{};
    }
}

