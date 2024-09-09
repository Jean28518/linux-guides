# Smartstore

```bash
sudo -i
cd && mkdir smartstore && cd smartstore && vim docker-compose.yml
# Insert:
version: '3.7'
services:
  db:
    # We use a mariadb image which supports both amd64 & arm64 architecture
    image: mariadb:latest
    # If you really want to use MySQL, uncomment the following line
    #image: mysql:8.0.27
    command: '--default-authentication-plugin=mysql_native_password'
    volumes:
      - ./db_data:/var/lib/mysql
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=Thu8vee5
      - MYSQL_DATABASE=smartstore
      - MYSQL_USER=smartstore
      - MYSQL_PASSWORD=ohb5AwoF
  snmartstore:
    image: ghcr.io/smartstore/smartstore-linux:latest
    ports:
      - 40924:80
    restart: unless-stopped



docker-compose up -d

vim /etc/caddy/Caddyfile
shop.int.de {
  reverse_proxy localhost:40924
}


systemctl restart caddy
```

- In the smartstore startup guide insert:
  - DB HOST: db
  - DB User: smartstore
  - DB Name: smartstore
  - DB User Password: ohb5AwoF
