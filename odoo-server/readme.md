## Official Odoo ERP System


### docker-compose.yml
```
version: "3.7"

services:
  db:
    image: postgres:13
    restart: unless-stopped
    environment:
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=odoo
      - POSTGRES_DB=postgres
    volumes: 
      - postgres-data:/var/lib/postgresql/data
  odoo:
    image: odoo
    restart: unless-stopped
    volumes:
      - odoo-data:/opt/odoo/data
    ports:
      - 5000:8069
    depends_on:
      - db

volumes:
  postgres-data:
  odoo-data:
```

The masterpassword for the setup is `ownerp2021`.

## Odoo ERP System from Equitania


### docker-compose.yml
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
      - odoo-data:/opt/odoo/data
    ports:
      - 5000:8069
    depends_on:
      - live-db

volumes:
  postgres-data:
  odoo-data:
```

The masterpassword for the setup is `ownerp2021`.