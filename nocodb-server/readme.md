# Nocodb Server
Spreadsheets on steroids. Datafields and handling of data is very good. But when it comes to advanced forms it isn't recommended. If you want to automate something a custom python script is recommended.

## Instructions for installation with docker:
<https://github.com/nocodb/nocodb/blob/develop/docker-compose/mysql/docker-compose.yml>

docker-compose.yml:

```docker-compose
version: "2.1"
services: 
  nocodb: 
    depends_on: 
      root_db: 
        condition: service_healthy
    environment: 
      NC_DB: "mysql2://root_db:3306?u=noco&p=faiTh8ra&d=root_db"
    image: "nocodb/nocodb:0.105.3" # Update the number to the latest version here: https://hub.docker.com/r/nocodb/nocodb/tags
    ports: 
      - "23260:8080"
    restart: unless-stopped
    volumes: 
      - "nc_data:/usr/app/data"
  root_db: 
    environment: 
      MYSQL_DATABASE: root_db
      MYSQL_PASSWORD: faiTh8ra
      MYSQL_ROOT_PASSWORD: faiTh8ra
      MYSQL_USER: noco
    healthcheck: 
      retries: 10
      test: 
        - CMD
        - mysqladmin
        - ping
        - "-h"
        - localhost
      timeout: 20s
    image: "mysql:8.0.32"
    restart: unless-stopped
    volumes: 
      - "db_data:/var/lib/mysql"
#    below line shows how to change charset and collation
#    uncomment it if necessary
#    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
volumes: 
  db_data: {}
  nc_data: {}
```

(You will need a proxy reverse server for https and advanced stuff)

Example caddy file:
```
DOMAIN {
  reverse_proxy localhost:23260
}
```



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
