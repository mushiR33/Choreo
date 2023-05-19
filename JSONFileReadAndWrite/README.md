# Integration Project To Persist Large Payloads
This is an integration project inmplemented using the WSO2 Integration Studio 8.1.0 to cater the requirement of persisting large payloads to the database. The flow of this project is as follows.

![Usecase](https://github.com/mushiR33/Choreo/assets/109526446/dfef9c72-0380-4256-8e9a-f11a7f08d762)

## Prerequisites

* Install JDK 11
* Install MySql database and create a schema call "Employee" and a table called "Student". The following os the script for the "Student" table.
```bash
    CREATE TABLE `Student` (
      `id` int NOT NULL AUTO_INCREMENT,
      `first_name` varchar(45) DEFAULT NULL,
      `last_name` varchar(45) DEFAULT NULL,
      `phone` varchar(45) DEFAULT NULL,
      PRIMARY KEY (`id`)
  ) ENGINE=InnoDB AUTO_INCREMENT=64410 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
 ```
* Download WSO2 Micro Integrator 4.2.0 from [1] and WSO2 Integration Studio 8.1.0 from [2]
* Extract the downloaded WSO2 Micro Integrator and open the following directory from the terminal. The extracted directory will be referred as <MI_HOME>.

```bash
    <MI_HOME>/bin
 ```

* Run the following command to start the server. If it is Windows run the micro-integrator.bat file

```bash
    sh micro-integrator.sh
 ```

## Import the project to the WSO2 Integration Studio

* Clone this repository.

    ```bash
    git clone https://github.com/mushiR33/Choreo
    cd JSONFileReadAndWrite
    ```
* In order to import this to the WSO2 Integration Studio, open the Integration Studio and go to File->Import and select "Existing WSO2 Projects into workspace" under "WSO2".
* Then select the root directory as "JSONFileReadAndWrite" directory which was cloned in the previous step.
* Once that is given select all the listed projects as shown below.
![Screen Shot 2023-05-19 at 5 38 21 PM](https://github.com/mushiR33/Choreo/assets/109526446/f1e93e46-b946-413a-99cb-9632d588780d)

* Now that the project is successfully imported you can make any changes if you wish.

## Export the complete package to the WSO2 Micro Integrator
* In order for this project to work we need to export this as a "Composite Application Project" to the WSO2 Micro Integrator.
* We can do that by right clicking on the "JSONFileReadAndWriteCompositeExporter" on the file structure and click on "Export Composite Application Project"
![Screen Shot 2023-05-19 at 4 41 57 PM](https://github.com/mushiR33/Choreo/assets/109526446/ae21fe72-47df-489c-a3ee-2892fd1d7f8a)

* You can give the export destination as <MI_HOME>/repository/deployment/server/carbonapps so that it would directly get deployed to Micro Integrator.
![Screen Shot 2023-05-19 at 4 45 21 PM](https://github.com/mushiR33/Choreo/assets/109526446/2978dcb8-7c55-40c4-8503-c32593a81e75)

* Then you can select which ever the projects that you need to include in this package. For this particular flow we need to select all the projects included here.
![Screen Shot 2023-05-19 at 4 46 06 PM](https://github.com/mushiR33/Choreo/assets/109526446/10a7f6fc-b582-41a8-960f-f716c4efe4bf)

* Finally you can click "Finish" and it will get deployed to the Micro Integrator which is already up and running. To make sure it is getting deployed, you can see the logs in the terminal where you started the Micro Integrator server.
<img width="1509" alt="Screen Shot 2023-05-19 at 4 52 56 PM" src="https://github.com/mushiR33/Choreo/assets/109526446/cecc6c7e-80ef-4ad0-b370-f812bf77e07b">

## Test the flow
* The sample JSON is as follows.
 ```bash
    {
    "students": [
        {
            "fname": "Chris",
            "lname": "Brook",
            "phone": "7655443"
        },
        {
            "fname": "Ross",
            "lname": "Taylor",
            "phone": "34543232"
        },
        {
            "fname": "Mark",
            "lname": "Mitch",
            "phone": "5346223"
        },
        {
            "fname": "Fahad",
            "lname": "Razick",
            "phone": "876543"
        }
    ]
}
 ```
* You can use any REST client tool such as Curl or Postman to test this flow. The following is a sample curl command.
```curl
curl --location 'http://localhost:8290/json/filepost' \
--header 'Content-Type: application/json' \
--data '<PATH_TO_THE_JSON>'
```

* Once the client sends a JSON payload you will be able to see the following logs in the terminal where the Micro Integrator runs. FileName would be the UUID of the message received by the Micro Integrator.
```bash
INFO {LogMediator} - {api:JsonAPI} PayloadLog = Payload written to file
INFO {LogMediator} - {api:JsonAPI} FileName = 99818abd-bc7f-42e7-a0ac-81620f072ebe.json
```

* Once the records have been persisted in the database the following log will get printed.
```bash
INFO {LogMediator} - {proxy:FileProxyService} EndLog = Records Persisted
```

* You also can verify this with database table whether the sent payload data has been perststed in the "Student" table.


    
1. https://wso2.com/micro-integrator/#
2. https://wso2.com/api-manager/tooling/
