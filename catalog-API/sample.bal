import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/graphql;
import ballerina/sql;

type Catalog record {
    @sql:Column {name: "item_id"}
    readonly int itemID;
    @sql:Column {name: "item_name"}
    string itemName;
    @sql:Column {name: "item_description"}
    string itemDesc;
    @sql:Column {name: "item_image"}
    string itemImage;
    // record {
    //     @sql:Column {name: "includes"}
    //     string includes;
    //     @sql:Column {name: "intended_for"}
    //     string intendedFor;
    //     @sql:Column {name: "color"}
    //     string color;
    //     @sql:Column {name: "material"}
    //     string material;
    // } stockDetails;
};

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;


public distinct service class CatalogData {
    private final readonly & Catalog catalogRecord;

    function init(Catalog catalogRecord) {
        self.catalogRecord = catalogRecord.cloneReadOnly();
    }

    resource function get itemID() returns int {
        return self.catalogRecord.itemID;
    }

    resource function get itemName() returns string {
        return self.catalogRecord.itemName;
    }

    resource function get itemDesc() returns string {
        return self.catalogRecord.itemDesc;
    }

    resource function get itemImage() returns string {
        return self.catalogRecord.itemImage;
    }

    // resource function get includes() returns string {
    //     return self.catalogRecord.stockDetails.includes;
    // }

    // resource function get intendedFor() returns string {
    //     return self.catalogRecord.stockDetails.intendedFor;
    // }

    // resource function get color() returns string {
    //     return self.catalogRecord.stockDetails.color;
    // }

    // resource function get material() returns string {
    //     return self.catalogRecord.stockDetails.material;
    // }
}
# A service representing a network-accessible GraphQL API
service / on new graphql:Listener(8090) {

    # A resource for generating greetings
    # Example query:
    # query GreetWorld{ 
    # greeting(name: "World") 
    # }
    # Curl command: 
    # curl -X POST -H "Content-Type: application/json" -d '{"query": "query GreetWorld{ greeting(name:\"World\") }"}' http://localhost:8090
    #
    # + return - string name with greeting message or error
    resource function get catalogs() returns Catalog[]|error {
        return getAllItems();
    }

}

mysql:Client mysqlEp = check new (host = HOST, user = USER, password = PASSWORD, database = DATABASE, port = PORT);

function getAllItems() returns Catalog[]|error {
    Catalog[] catalogs = [];
    stream<Catalog, error?> resultStream = mysqlEp->query(
        `SELECT * FROM items i, stock s where i.item_id=s.item_id`
    );
    check from Catalog catalog in resultStream
        do {
            catalogs.push(catalog);
        };
    check resultStream.close();
    return catalogs;
}
