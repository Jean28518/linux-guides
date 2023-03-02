# Nextcloud on Ubuntu Server with Caddy as Webserver

**Sources:**
- <https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html>
- <https://caddyserver.com/docs/install#debian-ubuntu-raspbian>


## Install prerequisites
```bash
sudo apt update && sudo apt upgrade && sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list && sudo apt update && sudo apt install mariadb-server php-gd php-mysql php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip php-fpm caddy unzip vim
```

## Prepare database
```bash
sudo mysql

CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'PASSWORD';
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';
FLUSH PRIVILEGES;
QUIT;
```

## Installation
```bash
wget https://download.nextcloud.com/server/releases/latest.zip
wget https://download.nextcloud.com/server/releases/latest.zip.md5
md5sum -c latest.zip.md5 < latest.zip
unzip latest.zip
sudo mkdir -p /var/www/
sudo cp -r nextcloud /var/www/
sudo chown -R www-data:www-data /var/www/nextcloud

sudo vim /etc/caddy/Caddyfile
```

```caddy
IP_ADRESS_OR_DOMAIN {
  root * /var/www/nextcloud
  file_server

  php_fastcgi unix//var/run/php/php-fpm.sock
  header {
    Strict-Transport-Security max-age=31536000; # enable HSTS
  }

  redir /.well-known/carddav /remote.php/dav 301
  redir /.well-known/caldav /remote.php/dav 301

  @forbidden {
    path /.htaccess
    path /data/*
    path /config/*
    path /db_structure
    path /.xml
    path /README
    path /3rdparty/*
    path /lib/*
    path /templates/*
    path /occ
    path /console.php
  }

  respond @forbidden 404
}
```

```bash
sudo systemctl restart caddy
```

Open webbrowser with the ip adress of the server, fill the setup dialog.

## Optimizations (recommended)

```bash
sudo vim /etc/php/8.1/fpm/php.ini

# Set memory_limit to 512M
```

```bash
sudo vim /etc/php/8.1/fpm/pool.d/www.conf 

# uncomment following lines by removing ';'
# ;env[HOSTNAME] = $HOSTNAME
# ;env[PATH] = /usr/local/bin:/usr/bin:/bin
# ;env[TMP] = /tmp
# ;env[TMPDIR] = /tmp
# ;env[TEMP] = /tmp
```

```bash
sudo systemctl restart php8.1-fpm.service

sudo crontab -u www-data -e
# Insert:
*/5  *  *  *  * php -f /var/www/nextcloud/cron.php
```

Go to the nextcloud admin page and change 'background tasks' to "Cron (recommended)"

**You are finished!**

## Move data directory to other partition:
In this example our partition is mounted under `/data`
```bash
sudo -i
mkdir /data/nextcloud
mv /var/www/nextcloud/data /data/nextcloud/
chmod a+rwx /data # Or alternatively chown the /data/ dir to www-data:www-data.
chown -R www-data:www-data /data/nextcloud/
vim /var/www/nextcloud/config/config.php
# Change datadirectory to: /data/nextcloud/data/
```
