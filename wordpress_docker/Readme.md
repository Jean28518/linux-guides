# Wordporess (with docker)

Docker-Compose

```docker-compose
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
```

## Caddyfile

```ỳaml
blog.int.de {
  reverse_proxy localhost:22122
}
```

## PHP Extensions

Wordpress docker container is an extended php container: <https://github.com/docker-library/docs/blob/master/php/README.md#how-to-install-more-php-extensions>

```bash
# Run inside the docker container
docker-php-ext-install pdo_mysql
```

## Change PHP-Values (e.g. upload sizce)

```bash
vim html/.htaccess
# Append:
php_value upload_max_filesize 500M
php_value post_max_size 500M


docker-compose restart
```
