# BackUp System Borg (mit Jeans Optimierungen)

In dieser Anleitung wird gezeigt, wie man auf einem Debian oder Ubuntu Server mit Borg ein vollautomatisches, sicheres und inkrementelles BackUp-System einrichtet. Als darunterliegende Technologie wird Borg verwendet.

## Vorbereitungen: 

* Debian oder Ubuntu Server als BackUp Server einrichten
* Am besten diesen Server bei einem anderen Serveranbieter mieten, oder bei sich Zuhause haben. Auf jeden Fall an einem anderen pyhsischen Ort.

## Source Server:

```bash
sudo -i && cd && ssh-keygen && cat ~/.ssh/id_rsa.pub
```

## BackUp Server:

```bash
sudo apt install borgbackup vim ncdu -y && sudo adduser borg # Keine Root Rechte!

su borg 
cd && mkdir .ssh

vim ~/.ssh/authorized_keys # Den Public key vom Source Server hinzufügen
command="borg serve --restrict-to-path /home/borg/backups/Server1 --append-only" # Das vor dem eben eingefügten Public Key einfügen

mkdir -p ~/backups/Server1


borg init --encryption=none ~/backups/Server1
borg config ~/backups/Server1 additional_free_space 10G
```

## Source Serer:

```bash
apt install borgbackup vim ncdu -y
vim ~/backup.sh
```
##### backup.sh:
```bash
#!/bin/bash

# Dump all databases
mysqldump -u root --all-databases > all_databases.sql
# To restore a Single MySQL Database from a Full MySQL Dump:
# mysql -u root -p database_name < all_databases.sql

# Get apt selection of packages:
/usr/bin/dpkg --get-selections | /usr/bin/awk '!/deinstall|purge|hold/'|/usr/bin/cut -f1 |/usr/bin/tr '\n' ' '  > installed-packages.txt  2>&1
# To restore apt packages:
# sudo apt update && sudo xargs apt install </root/installed-packages.txt

DATE=`date +"%Y-%m-%d"`
REPOSITORY="ssh://borg@1.2.3.4:22/~/backups/Server1"
borg create --exclude-caches --one-file-system $REPOSITORY::$DATE / -e /dev -e /prox -e /sys -e /tmp -e /run -e /media -e /mnt

# Alternative run, if server says "Connection closed by remote host. Is borg working on the server?" but borg is definitely installed at the target server. 
#borg create --remote-path /usr/local/bin/borg --exclude-caches --one-file-system $REPOSITORY::$DATE / -e /dev -e /prox -e /sys -e /tmp -e /run -e /media -e /mnt
```
   
    

```bash   
chmod 700 ~/backup.sh && ~/backup.sh # Austesten

crontab -e
0 2 * * * /root/backup.sh # daily at 2 am
```

### Create restore files:
```bash
vim ~/mount_backup.sh && chmod 700 ~/mount_backup.sh && vim ~/umount_backup.sh && chmod 700 ~/umount_backup.sh
```

```bash
#!/bin/bash

REPOSITORY="ssh://borg@1.2.3.4:22/~/backups/Server1"
borg mount $REPOSITORY /mnt

# Alternative run, if server says "Connection closed by remote host. Is borg working on the server?" but borg is definitely installed at the target server. 
#borg mount --remote-path /usr/local/bin/borg $REPOSITORY /mnt

echo "You can find your backups in /mnt. Please don't forget to umount your backups with '~/umount_backup.sh' afterwards."
```

```bash
#!/bin/bash

borg umount /mnt
```

## Backup Server

```bash
vim ~/prune-backup.sh
```
##### prune-backup.sh
```bash
#!/bin/bash
borg prune -v ~/backups/Server1 \
    --keep-daily=10 \
    --keep-weekly=6 \
    --keep-monthly=12
```

```bash
chmod 700 ~/prune-backup.sh && ~/prune-backup.sh # Austesten

crontab -e
0 9 * * * /home/borg/prune-backup.sh # daily at 9 am
```




