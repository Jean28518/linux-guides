# BackUp System 

In dieser Anleitung wird gezeigt, wie man auf einem Debian oder Ubuntu Server mit Borg ein vollautomatisches, sicheres und inkrementelles BackUp-System einrichtet. Als darunterliegende Technologie wird Borg verwendet.

## Video

<https://youtu.be/7ZgjElyUqZ4>

## Vorbereitungen: 

* Debian oder Ubuntu Server als BackUp Server einrichten
* Am besten diesen Server bei einem anderen Serveranbieter mieten, oder bei sich Zuhause haben. Auf jeden Fall an einem anderen pyhsischen Ort.

## Source Server:

```bash
ssh-keygen
cat ~/.ssh/id_rsa.pub
```

## BackUp Server:

```bash
sudo adduser serverbackup # Dem Nutzer keine Root Rechte erteilen!

su serverbackup
mkdir .ssh && nano ~/.ssh/authorized_keys

sudo nano ~/.ssh/authorized_keys # Den Public key vom Source Server hinzufügen
command="borg serve --restrict-to-path /home/serverbackup/backups/Server --append-only" # Das vor dem eben eingefügten Public Key einfügen

sudo apt install borgbackup
mkdir -p ~/backups/Server1

borg init --encryption=repokey ~/backups/Server1
borg key export ~/backups/Server1 ~/key-export # Diesen Schlüssel sicher aufbewahren und die Datei danach vom Server löschen.
```

## Source Serer:

```bash
sudo apt install borgbackup -y
nano ~/backup.sh
```
##### backup.sh:
```bash
#!/bin/bash

# Dump all databases
mysqldump -u root --all-databases > all_databases.sql
# To restore a Single MySQL Database from a Full MySQL Dump:
# mysql -p -o database_name < mysql_all_databases.sql
# Otherwise e.g.:
# mysql -u nextcloud -p nextcloud
# MariaDB [nextcloud]> source mysql_export.sql

# Get apt selection of packages:
/usr/bin/dpkg --get-selections | /usr/bin/awk '!/deinstall|purge|hold/'|/usr/bin/cut -f1 |/usr/bin/tr '\n' ' '  > installed-packages.txt  2>&1
# To restore apt packages:
# sudo apt install </root/installed-packages.txt

DATE=`date +"%Y-%m-%d"`
REPOSITORY="ssh://serverbackup@1.2.3.4:22/~/backups/Server1"
export BORG_PASSPHRASE="MeineSuperSicherePassphrase"
borg create $REPOSITORY::$DATE /etc /home /opt /root /usr /var/www /var/lib /var/log --exclude-caches

# Alternative run, if server says "Connection closed by remote host. Is borg working on the server?" but borg is definitely installed at the target server. 
#borg create --remote-path /usr/local/bin/borg $REPOSITORY::$DATE /etc /home /opt /root /usr /var/www /var/lib /var/log --exclude-caches
```
   
    

```bash   
chmod +x ~/backup.sh
~/backup.sh # Austesten

crontab -e
0 2 * * * /home/jean/backup.sh # Jeden Tag um 2:00 Uhr
```

## Backup Server

```bash
nano ~/prune-backup.sh
```
##### prune-backup.sh
```bash
#!/bin/bash
export BORG_PASSPHRASE="MeineSuperSicherePassphrase"
borg prune -v ~/backups/Server1 \
    --keep-daily=10 \
    --keep-weekly=6 \
    --keep-monthly=12
```

```bash
chmod +x ~/prune-backup.sh
~/prune-backup.sh # Austesten

crontab -e
0 9 * * * /home/serverbackup/prune-backup.sh # Jeden Tag um 9:00 Uhr
```
