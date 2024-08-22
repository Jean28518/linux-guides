# Guacamole

We will do this with mysql.

```bash
cd && mkdir guacamole && cd guacamole && vim docker-compose.yml
```

```yaml
services:
    guacamole:
        image: guacamole/guacamole
        container_name: guacamole
        restart: always
        ports:
            - 15824:8080
        environment:
            - MYSQL_HOSTNAME=mysql
            - MYSQL_DATABASE=guacamole
            - MYSQL_USER=guacamole
            - MYSQL_PASSWORD=guacamole
            - GUACD_HOSTNAME=guacd
        depends_on:
            - mysql
    mysql:
        image: mysql
        container_name: mysql
        restart: always
        environment:
            - MYSQL_DATABASE=guacamole
            - MYSQL_USER=guacamole
            - MYSQL_PASSWORD=guacamole
            - MYSQL_ROOT_PASSWORD=guacamole
    guacd:
        image: guacamole/guacd
        container_name: guacd
        restart: always
```

```bash
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql
docker-compose up -d
docker cp initdb.sql mysql:/initdb.sql

docker exec -it mysql bash
mysql -u guacamole -p guacamole < /initdb.sql
exit

vim /etc/caddy/Caddyfile
```

```caddy
guacamole.int.de {
    rewrite * /guacamole{uri}
    reverse_proxy localhost:15824
}
```

```bash
systemctl restart caddy
```

```bash
docker-compose up -d
vim /etc/caddy/Caddyfile
```

```caddy
guacamole.int.de {
    reverse_proxy guacamole:15824
}
```

```bash
systemctl restart caddy
```

The initial credentials are `guacadmin` and `guacadmin`.