# Wordporess (with docker)

Docker-Compose:

```docker-compose
version: '3.7'

services:
  db:
    # We use a mariadb image which supports both amd64 & arm64 architecture
    image: mariadb:10.6.4-focal
    # If you really want to use MySQL, uncomment the following line
    #image: mysql:8.0.27
    command: '--default-authentication-plugin=mysql_native_password'
    volumes:
      - db_data:/var/lib/mysql
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=Thu8vee5
      - MYSQL_DATABASE=wordpress
      - MYSQL_USER=wordpress
      - MYSQL_PASSWORD=Thu8vee5
  wordpress:
    image: wordpress:latest
    volumes:
      - ./html:/var/www/html
    ports:
      - 22122:80
    restart: unless-stopped
    environment:
      - WORDPRESS_DB_HOST=db
      - WORDPRESS_DB_USER=wordpress
      - WORDPRESS_DB_PASSWORD=Thu8vee5
      - WORDPRESS_DB_NAME=wordpress
volumes:
  db_data:
```

## Caddyfile:

```ỳaml
blog.int.de {
  reverse_proxy localhost:22122
}
```
