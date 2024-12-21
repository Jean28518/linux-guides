# Nextcloud on Ubuntu Server with Caddy as Webserver

Automation script: <https://github.com/Jean28518/linux-arbeitsplatz-central/blob/main/src/lac/welcome/scripts/setup_nextcloud.sh>

**Sources:**

- <https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html>
- <https://caddyserver.com/docs/install#debian-ubuntu-raspbian>

## Install prerequisites

```bash
# Install caddy:
sudo apt update && sudo apt upgrade && sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list && sudo apt update && sudo apt install caddy

# Install dbms, php and other tools
sudo apt install mariadb-server php-gd php-mysql php-curl php-mbstring php-intl php-imap php-gmp php-bcmath php-xml php-imagick libmagickcore-6.q16-6-extra php-zip php-bz2 php-fpm php-redis php-apcu php-memcache unzip vim
```

## Prepare database

```bash
sudo mysql

CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'phoo2Oot';
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

  php_fastcgi unix//var/run/php/php-fpm.sock {

  }

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
sudo ufw allow http
sudo ufw allow https
sudo systemctl restart caddy
```

Open webbrowser with the ip adress of the server, fill the setup dialog.
Mysql PW: `phoo2Oot`

```bash
# Alternative install command (Don't forget to replace 'PASSWORD':
sudo -u www-data php /var/www/nextcloud/occ maintenance:install --database "mysql" --database-name "nextcloud"  --database-user "nextcloud" --database-pass "phoo2Oot" --admin-user "Administrator" --admin-pass "PASSWORD"
```

## Optimizations (recommended)

```bash
cd /var/www/nextcloud
sudo -u www-data php occ config:app:set dav system_addressbook_exposed --value="no"
sudo -u www-data php /var/www/nextcloud/occ config:system:set maintenance_window_start --value=1

sudo vim /etc/php/8.2/fpm/php.ini

# Set 
# memory_limit = 1024M
# upload_max_filesize = 10G
# max_file_uploads = 1000

# Add in the end:
opcache.interned_strings_buffer = 128
opcache.memory_consumption = 2048

```

```bash
sudo vim /var/www/nextcloud/config/config.php

# Add the following setting:
"default_phone_region" => 'DE',
'mail_smtptimeout' => '30',

# Change the ip adress to the IPv4 adress of the nextcloud server itself.
'trusted_proxies' => ['192.168.178.10'],
'bulkupload.enabled' => false,
```

```bash
sudo vim /etc/php/8.2/fpm/pool.d/www.conf 

# uncomment following lines by removing ';'
# ;env[HOSTNAME] = $HOSTNAME
# ;env[PATH] = /usr/local/bin:/usr/bin:/bin
# ;env[TMP] = /tmp
# ;env[TMPDIR] = /tmp
# ;env[TEMP] = /tmp
```

```bash
sudo systemctl restart php8.2-fpm.service

sudo crontab -u www-data -e
# Insert:
*/5  *  *  *  * php -f /var/www/nextcloud/cron.php
```

Go to the nextcloud admin page and change 'background tasks' to "Cron (recommended)"

## Redis

```bash
cd && mkdir redis-nextcloud && cd redis-nextcloud && vim docker-compose.yml

# Create the following file:
version: "3.9"
services:
  redis:
    restart: unless-stopped
    image: "redis:alpine3.17"
    ports:
      - 17423:6379
    command: redis-server --requirepass rahBieF7

docker-compose up -d

vim /var/www/nextcloud/config/config.php
# Add the following lines:
  'memcache.distributed' => '\OC\Memcache\Redis',
  'redis' => array(
     'host' => 'localhost',
     'port' => 17423,
     'timeout' => 0.0,
     'password' => 'rahBieF7'
  ),
  'memcache.locking' => '\OC\Memcache\Redis',
  'filelocking.enabled' => true,
  'memcache.local' => '\OC\Memcache\APCu',


PHP_VERSION=`php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2`
echo "apc.enable_cli=1" >> /etc/php/$PHP_VERSION/fpm/php.ini
echo "apc.enable_cli=1" >> /etc/php/$PHP_VERSION/cli/php.ini
```

## Setup in Nextcloud itself

- Install Groupfolders
- (Install External sites)
- (Install Deck)
- (Install Tasks)
- (Install Collectives)
  (Install Draw.io)
- Uninstall Activities
- Uninstall Collaborative Tags
- Uninstall First run wizard
- Uninstall Talk (and all other main apps which are not used)
- Uninsstall Nextcloud Announcements
- Uninstall Support
- Uninstall Usage Survey
- Change background: https://raw.githubusercontent.com/Jean28518/linux-arbeitsplatz-portal/main/images/background.webp

### External sites

| Service     | Name     | Additional information                                     | Activate forwarding |
|-------------|----------|------------------------------------------------------------| ------------------- |
| Jitsi       | Meetings |                                                            |           X         |
| NocoDB      | NocoDB   |                                                            |                     |
| Rocket.Chat | Chat     | Change X-Frame-Options to: sameorigin https://cloud.int.de |                     |
| Videoportal | Videos   |                                                            |                     |
| IPA         | Passwort ändern | Only upload dark key icon, position: settings menu  |           X         |

## Quality Check:
- All Nextcloud sites should be loaded in 2 seconds.
- Enter every nextcloud site at the top (sometimes the activities app makes trouble)
- Open a document for online editing (if collabora or only office are included)
- Verify that the cron job is running
- Check the administration messages (in administration overview)

**You are finished!**

## Move data directory to other partition

In this example our partition is mounted under `/data`

```bash
sudo -i
mkdir -p /data/nextcloud
chown -R www-data:www-data /data
mv /var/www/nextcloud/data /data/nextcloud/
chown -R www-data:www-data /data
vim /var/www/nextcloud/config/config.php
# Change datadirectory to: /data/nextcloud/data/
```

## Set Refreshrate for subscribed calendars
https://www.php.net/manual/de/dateinterval.construct.php
```bash
sudo -u www-data php /var/www/nextcloud/occ config:app:set dav calendarSubscriptionRefreshRate --value "PT30M"
```

## Import data from old machine

```bash
## On the new machine:
mkdir /data/import # run this as user, not as root, if you have the option

## Start on the other machine:
sftp user@newserver
put -r /path/to/old/data/* /data/import/

## Otherwise you can mount a backup and restore it like this:
rsync -aP /mnt/1970-01-01/data/nextcloud/ /data/

## On the new machine:
sudo convmv -f utf-8 -t utf-8 -r --notest --nfc /data/import/* # Convert filenames to right name
sudo mv /data/import/* /data/nextcloud/users/...
sudo chown www-data:www-data -R /data/nextcloud
sudo -u www-data php /var/www/nextcloud/occ files:scan --all
```

## To many requests from your IP

If you tried to login too many times:

```bash
sudo -u www-data php /var/www/nextcloud/occ security:bruteforce:reset <IP>
# You need only the '--define apc.enable_cli=1' if you have the redis module enabled.
```

## On Nextcloud Updates

Check before the update, if the installed php version is supported by the following nextcloud version!!

- Nextcloud 25 needs php 8.0 or higher

### Update via terminal

```bash
sudo -u www-data php /var/www/nextcloud/updater/updater.phar --no-interaction

# Manuell:
sudo -u www-data php /var/www/nextcloud/updater/updater.phar
sudo -u www-data php /var/www/nextcloud/occ upgrade
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off
```

### After update

```bash
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-indices # helps after update
sudo -u www-data php /var/www/nextcloud/occ maintenance:repair --include-expensive
```

## Reset password manually

```bash
sudo -u www-data php /var/www/nextcloud/occ user:resetpassword USERNAME
```

## Nextcloud down? Nothing works?

Check, if a basic command runs. Otherwise it is printed a stack trace.

```bash
sudo -u www-data php /var/www/nextcloud/occ -V

# Sometimes it just helps to restart the mysql service

# Other helpful commands:
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-columns
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-indices
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-primary-keys
sudo -u www-data php /var/www/nextcloud/occ maintenance:repair


```

Good luck!

## Restore nextcloud from backup

For example if an update went wrong...

```bash
systemctl stop mariadb
# If an update got wrong, then the next line could be useful to reset the updater:
# rm -r /data/nextcloud/updater*
rsync -aP /mnt/2024-04-25-system/var/www/nextcloud/ /var/www/nextcloud/ --exclude=/var/www/nextcloud/data/ --delete
rsync -aP /mnt/2024-04-25-system/var/lib/mysql /var/lib/mysql
systemctl start mariadb
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off
```
