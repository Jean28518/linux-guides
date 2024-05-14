# Matomo

## docker-compose.yaml
```yaml
version: "3"

services:
  db:
    image: mariadb:10.11
    command: --max-allowed-packet=64MB
    restart: unless-stopped
    volumes:
      - ./db:/var/lib/mysql:Z
    environment:
      - MYSQL_ROOT_PASSWORD=
      - MARIADB_AUTO_UPGRADE=1
      - MARIADB_DISABLE_UPGRADE_BACKUP=1

  app:
    image: matomo
    restart: unless-stopped
    volumes:
      - ./matomo:/var/www/html:z
    environment:
      - MATOMO_DATABASE_HOST=db
    ports:
      - 14524:80
```

## Caddy
```caddy
matomo.int.de {
  reverse_proxy localhost:14524
}
```

