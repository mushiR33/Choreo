import ballerina/http;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;
import ballerina/log;

type Item record {
    @sql:Column {name: "item_id"}
    readonly int itemID;
    @sql:Column {name: "item_name"}
    string itemName;
    @sql:Column {name: "item_description"}
    string itemDesc;
    @sql:Column {name: "item_image"}
    string itemImage;
    @sql:Column {name: "s.includes"}
    string includes;
    @sql:Column {name: "intended_for"}
    string intendedFor;
    @sql:Column {name: "color"}
    string color;
    @sql:Column {name: "material"}
    string material;
    @sql:Column {name: "price"}
    decimal price;
};

type Catalog record {
    readonly int itemID;
    string itemName;
    string itemDesc;
    string itemImage;
    decimal price;
    StockDetails stockDetails;

};

type StockDetails record {
    string includes;
    string intendedFor;
    string color;
    int quantity;
    string material;
};

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

mysql:Client mysqlEp = check new (host = HOST, user = USER, password = PASSWORD, database = DATABASE, port = PORT, connectionPool = {maxOpenConnections: 3});

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function post items(@http:Payload Catalog itemPayload) returns http:Created|http:BadRequest|error|int {
        sql:ExecutionResult result = check mysqlEp->execute(`
            INSERT INTO items (item_name, item_description, item_image, price)
            VALUES (${itemPayload.itemName}, ${itemPayload.itemDesc}, ${itemPayload.itemImage},  
                    ${itemPayload.price})
        `);
        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            sql:ExecutionResult stockResult = check mysqlEp->execute(`
            INSERT INTO stock (item_id, quantity, includes, price, color, material, intended_for)
            VALUES (${lastInsertId}, ${itemPayload.stockDetails.quantity}, ${itemPayload.stockDetails.includes},  
                    ${itemPayload.price}, ${itemPayload.stockDetails.color}, ${itemPayload.stockDetails.material}, 
                    ${itemPayload.stockDetails.intendedFor})
            `);
            int|string? insertId = stockResult.lastInsertId;
            if insertId is int {
                return <http:Created>{};
            } else {
                return error("Unable to obtain last insert ID of the Stock");
            }
        } else {
            return error("Unable to obtain last insert ID of the Item");
        }
    }

    resource function put items/[int itemID](@http:Payload Catalog itemPayload) returns http:Ok|http:NotFound|error {
        sql:ExecutionResult result = check mysqlEp->execute(`
            UPDATE items SET
                item_name = ${itemPayload.itemName}, 
                item_description = ${itemPayload.itemDesc},
                item_image = ${itemPayload.itemImage},
                price = ${itemPayload.price}
            WHERE item_id = ${itemPayload.itemID}  
        `);

        sql:ExecutionResult resultStock = check mysqlEp->execute(`
            UPDATE stock SET
                includes = ${itemPayload.stockDetails.includes}, 
                price = ${itemPayload.price},
                color = ${itemPayload.stockDetails.color},
                material = ${itemPayload.stockDetails.material},
                quantity = ${itemPayload.stockDetails.quantity},
                intended_for = ${itemPayload.stockDetails.intendedFor}
            WHERE item_id = ${itemPayload.itemID}  
        `);
        if result.affectedRowCount > 0 && resultStock.affectedRowCount > 0 {
            return <http:Ok>{};
        } else {
            return error("Unable to update");
        }
    }
}
