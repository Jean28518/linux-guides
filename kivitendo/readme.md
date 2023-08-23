# Kivitendo 3.8.0

<https://github.com/kivitendo/kivitendo-erp/tags>

With Caddy as reverse proxy on ubuntu.

```bash
sudo -i
apt install apache2 libarchive-zip-perl libclone-perl \
  libconfig-std-perl libdatetime-perl libdbd-pg-perl libdbi-perl \
  libemail-address-perl  libemail-mime-perl libfcgi-perl libjson-perl \
  liblist-moreutils-perl libnet-smtp-ssl-perl libnet-sslglue-perl \
  libparams-validate-perl libpdf-api2-perl librose-db-object-perl \
  librose-db-perl librose-object-perl libsort-naturally-perl \
  libstring-shellquote-perl libtemplate-perl libtext-csv-xs-perl \
  libtext-iconv-perl liburi-perl libxml-writer-perl libyaml-perl \
  libimage-info-perl libgd-gd2-perl libapache2-mod-fcgid \
  libfile-copy-recursive-perl postgresql libalgorithm-checkdigits-perl \
  libcrypt-pbkdf2-perl git libcgi-pm-perl libtext-unidecode-perl libwww-perl \
  postgresql-contrib poppler-utils libhtml-restrict-perl \
  libdatetime-set-perl libset-infinite-perl liblist-utilsby-perl \
  libdaemon-generic-perl libfile-flock-perl libfile-slurp-perl \
  libfile-mimeinfo-perl libpbkdf2-tiny-perl libregexp-ipv6-perl \
  libdatetime-event-cron-perl libexception-class-perl libcam-pdf-perl \
  libxml-libxml-perl libtry-tiny-perl libmath-round-perl \
  libimager-perl libimager-qrcode-perl librest-client-perl libipc-run-perl postgresql-contrib poppler-utils

# Download the newest kvitendo.zip source code from here:
cd /var/www/
git clone https://github.com/kivitendo/kivitendo-erp.git
cd kivitendo-erp/
# Checkout to the commit code of the latest realease: https://github.com/kivitendo/kivitendo-erp/tags
git checkout ae23944 

mkdir webdav
cp config/kivitendo.conf.default config/kivitendo.conf
chown -R www-data /var/www/kivitendo-erp/
vim config/kivitendo.conf

# Change the following variables:
[authentication]
admin_password = geheim

[authentication/database]
host     = localhost
port     = 5432
db       = kivitendo
user     = kivitendo
password = iXie1XaC

[system]
default_manager = german

# Under [task_server] ensure:
run_as = www-data

sudo -u postgres createuser -P -d kivitendo # PW: iXie1XaC
sudo -u postgres createdb -O kivitendo kivitendo 
vim /etc/postgresql/14/main/pg_hba.conf
# Add: 
local all kivitendo password
host all kivitendo 127.0.0.1 255.255.255.255 password

# Set postgres admin user password (this is important, execute the commands one by one)
su - postgres
psql
\password postgres
# Enter iXie1XaC
\q
exit


sudo systemctl restart postgresql

vim /etc/apache2/ports.conf
# Change Ports to 8080 and 8443


vim /etc/apache2/apache2.conf
# Add to the end: 
AliasMatch ^/[^/]+\.pl /var/www/kivitendo-erp/dispatcher.fcgi
Alias       /          /var/www/kivitendo-erp/

<Directory /var/www/kivitendo-erp/>
  AllowOverride All
  Options ExecCGI Includes FollowSymlinks
  Require all granted
</Directory>

<DirectoryMatch /var/www/kivitendo-erp/users>
Require all denied
</DirectoryMatch>

<DirectoryMatch "/(\.git|config)/">
Require all denied
</DirectoryMatch>


vim /etc/apache2/sites-enabled/000-default.conf
# Ensure:
<VirtualHost *:8080>

        DocumentRoot /var/www/kivitendo-erp
        Include conf-available/serve-cgi-bin.conf


a2enmod fcgid
systemctl restart apache2

cp scripts/boot/systemd/kivitendo-task-server.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable kivitendo-task-server.service --now
# It is completely normal that the startup fails at this time. Just ignore it. 
# After we completed the first steps further down, the service works nomally.
```

## Caddy configuration

```Caddyfile
kivi.int.de {
  reverse_proxy localhost:8080
}
```

## First steps

**You don't need to create a user if you want to use ldap.**

- Open up the site. At the beginning an error ("Authentifizieruns Datenbank kann nicht erreicht werden") occurs. That's normal. Click on "Administration" at the bottom
- Login with your Admin password.
- Click on "Create table"
- Head over to database administration, click on "create new database"
  - Insert "company1" into new database field
  - Insert "postgres" into the superuser field, and enter his password: iXie1XaC
- Create a new user by hovering to "Benutzer, Mandanten und Benutzergruppen" -> "New user" (Username: lower case)
  - If you want, add the user to the group "Vollzugriff" in the end of the site.
  - Change the .css design to "design40.css"
- Create a new "Mandant"
  - Name: company1
  - dbname: company1
  - Run taskserver as: username
  - Add the user with access to the "Mandant"
  - Add "Vollzugriff"
- Now you can login as a normal user. And everything should work.
