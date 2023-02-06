# Nocodb Server
Spreadsheets on steroids. Datafields and handling of data is very good. But when it comes to advanced forms it isn't recommended. If you want to automate something a custom python script is recommended.

## Instructions for installation with docker:
<https://github.com/nocodb/nocodb/blob/develop/docker-compose/mysql/docker-compose.yml>

(You will need a proxy reverse server for https and advanced stuff)

## How to call the nocodb API with python script and implement fully automatic workflows
```bash
sudo pip3 install nocodb
```
This script is used to update single entries of a table every 10 seconds.
```python
from nocodb.nocodb import NocoDBProject, APIToken, JWTAuthToken
from nocodb.filters import InFilter, EqFilter
from nocodb.infra.requests_client import NocoDBRequestsClient
import time


# Usage with API Token
client = NocoDBRequestsClient(
        # Your API Token retrieved from NocoDB conf
        APIToken("###"),
        # Your nocodb root path
        "https://db.int.de"
)

project = NocoDBProject(
        "noco", # org name. noco by default
        "r4_p17" # project name. Case sensitive!!
)

def update_db():
    print("Updating...")
    table_name = "Linux-Support"

    table_rows = client.table_row_list(project, table_name)["list"]

    for row in table_rows:
        id = row["Id"]
        if row["Title"] != f"Ticket {id}":
            client.table_row_update(project, table_name, id, {"Title": f"Ticket {id}"})

        if row["Rechnung versendet"] == 1:
            client.table_row_update(project, table_name, id, {"Status": "Erledigt"})
        
        # If you want you can also update the whole row but that isn't recommended because of too many unrequired api calls on big datasets
        # Also race conditions while editing in the webui are rarer if you don't use the line underneath
        # client.table_row_update(project, table_name, id, row)


    # print(table_rows)

if __name__ == "__main__":
    while True:
        update_db()
        time.sleep(10)
```