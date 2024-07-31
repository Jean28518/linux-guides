# Dolibarr

On blank Debian 12.

```bash
sudo -i
apt update && apt upgrade -y
# Let's install the required packages (LAMP stack). But with mariadb and caddy
apt install mariadb-server mariadb-client php php-mysql php-curl php-gd php-intl php-mbstring php-xml php-zip php-apcu php-imagick php-ldap php-xmlrpc php-soap php-bcmath php-gmp caddy git php-fpm php-imap -y

# Let's secure the mariadb installation
mysql_secure_installation

# Let's create the database and a user for dolibarr
mysql
CREATE DATABASE dolibarr;
CREATE USER 'dolibarr'@'localhost' IDENTIFIED BY 'dolibarr';
GRANT ALL PRIVILEGES ON dolibarr.* TO 'dolibarr'@'localhost';
FLUSH PRIVILEGES;
QUIT;

# Let's download the latest version of dolibarr via git
cd /var/www/
git clone https://github.com/Dolibarr/dolibarr.git
cd dolibarr
git config --global --add safe.directory /var/www/dolibarr
git checkout 20.0
touch /var/www/dolibarr/htdocs/conf/conf.php
chown -R www-data:www-data /var/www/dolibarr


# Let's configure caddy
vim /etc/caddy/Caddyfile
```

```caddy
dolibarr.int.de {
  root * /var/www/dolibarr/htdocs
  file_server
  php_fastcgi unix//run/php/php8.2-fpm.sock
  encode zstd gzip
  header {
    Strict-Transport-Security max-age=31536000;
    X-Content-Type-Options nosniff
    X-Frame-Options DENY
    Referrer-Policy no-referrer-when-downgrade
    X-XSS-Protection 1; mode=block
  }
}
```

```bash
systemctl restart caddy
```

- Go to: `http://dolibarr.int.de/install/`
- Follow the installation wizard
  - In the mysql settings, use the following:
    - Database server: `localhost`
    - Database name: `dolibarr`
    - Database user: `dolibarr`
    - Database password: `dolibarr`
    - leave the rest unchanged

```bash
# Let's set the install.lock file
touch /var/www/dolibarr/documents/install.lock
chown -R www-data:www-data /var/www/dolibarr
# And let's secure the conf.php file
chmod 400 /var/www/dolibarr/htdocs/conf/conf.php
```
