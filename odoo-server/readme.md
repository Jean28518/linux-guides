# Odoo ERP System from Equitania


## docker-compose.yml
```
version: "3.7"

services:
  live-db:
    image: postgres:12.6-alpine
    restart: unless-stopped
    environment:
      - POSTGRES_USER=ownerp
      - POSTGRES_PASSWORD=ownerp2021
      - POSTGRES_DB=postgres
    volumes: 
      - postgres-data:/var/lib/postgresql/data
  odoo:
    image: myodoo/myodoo-13-public:210206
    restart: unless-stopped
    command: start
    volumes:
      - myodoo13-data:/opt/odoo/data
    ports:
      - 5000:8069
    depends_on:
      - live-db



volumes:
  postgres-data:
  myodoo13-data:
```

The masterpassword for the setup is `ownerp2021`.