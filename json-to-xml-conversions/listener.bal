import ballerina/file;
import ballerina/log;
import ballerina/io;
import ballerinax/mysql;
import ballerina/sql;

type StudentsItem record {|
    string fname;
    string lname;
    string phone;
|};

type Students record {
    StudentsItem[] students;
};

// The listener monitors any modifications done to a specific directory.
listener file:Listener inFolder = new ({
    path: "/Users/mushthaqrumy/Documents/APIM/Choreo/Choreo-GIT/Choreo/json-to-xml-conversions/files",
    recursive: false
});

mysql:Client db = check new ("localhost", "root", "root", "Employees", 3306);

// The directory listener should have at least one of these predefined resources.
service "localObserver" on inFolder {

    // This function is invoked once a new file is created in the listening directory.
    remote function onCreate(file:FileEvent m) {
        log:printInfo("Create: " + m.name);
        do {
	        json readJson = check io:fileReadJson(m.name);
            log:printInfo("After Read JSON!!!");
            log:printInfo("Before Clone!!!");
            Students students = check readJson.cloneWithType(Students);
            log:printInfo("After Clone JSON!!!");
            // Create a batch parameterized query.
            sql:ParameterizedQuery[] insertQueries = from StudentsItem studentsItem in students.students
            select `INSERT INTO Student (first_name, last_name, phone) 
                    VALUES (${studentsItem.fname}, ${studentsItem.lname}, ${studentsItem.phone})`;

        // Insert records in a batch.
        log:printInfo("Before DB Write!!!");
        _ = check db->batchExecute(insertQueries);
        log:printInfo("Processing completed!!!");
        check file:remove(m.name);
        log:printInfo("File removed successfully!!!");
            //io:println(readJson);
        } on fail var e {
        	log:printInfo("Error while reading json: " + e.message());
        }
    }

    // This function is invoked once an existing file is deleted from the listening directory.
    remote function onDelete(file:FileEvent m) {
        log:printInfo("Delete: " + m.name);
    }

    // This function is invoked once an existing file is modified in the listening directory.
    remote function onModify(file:FileEvent m) {
        log:printInfo("Modify: " + m.name);
    }
}