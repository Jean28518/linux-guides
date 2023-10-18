# BackUp System Borg (mit Jeans Optimierungen)

In dieser Anleitung wird gezeigt, wie man auf einem Debian oder Ubuntu Server mit Borg ein vollautomatisches, sicheres und inkrementelles BackUp-System einrichtet. Als darunterliegende Technologie wird Borg verwendet.

## Vorbereitungen

* Debian oder Ubuntu Server als BackUp Server einrichten
* Am besten diesen Server bei einem anderen Serveranbieter mieten, oder bei sich Zuhause haben. Auf jeden Fall an einem anderen pyhsischen Ort.

## Source Server

```bash
sudo -i 
cd && ssh-keygen && cat ~/.ssh/id_rsa.pub
apt install borgbackup vim ncdu -y
```

## BackUp Server

### Linux-Server

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

### Hetzner Storage Box

* enable SSH Support on your Hetzner Storage Box
* run on the source server:

```bash
ssh-copy-id -i .ssh/id_rsa -p 23 -s USER@SERVERADRESS
borg init --encryption=repokey ssh://USER@SERVERADRESS:23/./borg-SERVERNAME
# Create a strong password WITHOUT special characters and save it safe!
borg key export ssh://USER@SERVERADRESS:23/./borg-SERVERNAME
# Save this repokey securely!
# You will need both parts to recover borg-backup
```

### Synology

* create group called 'borg'
* create user called 'borg' in synology admin interface, add him to borg and administrator groups
* add SynoCommunity repo `https://packages.synocommunity.com/`
* intall Borg from Synco Community Repo
* enable ssh in the system settings under 'Terminal & SNMP'
* connect to ssh with the borg user.
* ensure that the borg user can write in his home directory and the home directory points to a volume. You can become root by typing 'sudo -i' and entering the password of the borg user.

```
mkdir -p ~/backups/Server1


borg init --encryption=none ~/backups/Server1
borg config ~/backups/Server1 additional_free_space 10G
```

#### Add SSH-Key

```bash
mkdir -p /var/services/homes/borg/.ssh
chmod 0700 /var/services/homes/borg-backup
chmod 0700 /var/services/homes/borg-backup/.ssh
echo "FULL_PUBKEY" > /var/services/homes/borg-backup/.ssh/authorized_keys
chmod 0600 /var/services/homes/borg-backup/.ssh/authorized_keys
```

On the source server add an special ssh config file

```bash
vim ~/.ssh/config

# Paste this into:
Host *
  SendEnv LANG LC_*
  Ciphers +aes256-cbc
```

Now the ssh key should work properly.

## Source Serer

```bash
vim ~/backup.sh
```

### backup.sh

```bash
#!/bin/bash
HOSTNAME=$(hostname)
RECEPIENT=mail@int.de

# Dump all databases
# --default-character-set=utf8mb4: For emojis and similar, otherwise its broken 
mysqldump -u root --all-databases --default-character-set=utf8mb4 > all_databases.sql    
# To restore a Single MySQL Database from a Full MySQL Dump:
# mysql -p -o database_name < all_databases.sql

# Get apt selection of packages:
/usr/bin/dpkg --get-selections | /usr/bin/awk '!/deinstall|purge|hold/'|/usr/bin/cut -f1 |/usr/bin/tr '\n' ' '  > installed-packages.txt  2>&1
# To restore apt packages:
# sudo apt update && sudo xargs apt install </root/installed-packages.txt

# Stop all services
#systemctl stop docker
#systemctl stop freeipa.service
#systemctl stop vm-li-ar.service


DATE=`date +"%Y-%m-%d"`
REPOSITORY="ssh://borg@1.2.3.4:22/~/backups/Server1"
#REPOSITORY="ssh://USER@SERVERADRESS:23/./borg-SERVERNAME"
#export BORG_PASSPHRASE="XXXXX"

echo "Running borg create ..."

borg create --exclude-caches $REPOSITORY::$DATE / -e /dev -e /proc -e /sys -e /tmp -e /run -e /media -e /mnt -e /var/log 2> backup_errors.txt

# Alternative run, if server says "Connection closed by remote host. Is borg working on the server?" but borg is definitely installed at the target server. 
#borg create --remote-path /usr/local/bin/borg --exclude-caches $REPOSITORY::$DATE / -e /dev -e /proc -e /sys -e /tmp -e /run -e /media -e /mnt -e /var/log 2> backup_errors.txt

# Send Mail
if [ $? -eq 0 ]; then
  echo -e "Backup for $HOSTNAME was successful." | mail -a 'From: SERVERNAME <kunden@linuxguides.de>' -s "💾✅ $HOSTNAME: Backup Success" $RECEPIENT -A backup_errors.txt
else
  echo -e "Backup for $HOSTNAME was not successful. The attachement file should explain why." | mail -a 'From: SERVERNAME <kunden@linuxguides.de>' -s "💾❌ $HOSTNAME: Backup ERROR❌" $RECEPIENT -A backup_errors.txt
fi


borg prune -v $REPOSITORY \
    --keep-daily=14 \
    --keep-weekly=12 \
    --keep-monthly=24

# MAINTENANCE ###############################

# Update system after backup
export DEBIAN_FRONTEND="noninteractive"
apt dist-upgrade -y

# Reboot server
/sbin/reboot
```

```bash
chmod 700 ~/backup.sh && ~/backup.sh # Austesten

crontab -e
0 2 * * * /root/backup.sh # daily at 2 am
```

### Create restore files

```bash
vim ~/mount_backup.sh && chmod 700 ~/mount_backup.sh && vim ~/umount_backup.sh && chmod 700 ~/umount_backup.sh
```

```bash
#!/bin/bash

REPOSITORY="ssh://borg@1.2.3.4:22/~/backups/Server1"
#REPOSITORY="ssh://USER@SERVERADRESS:23/./borg-SERVERNAME"
#export BORG_PASSPHRASE="XXXXX"

borg mount $REPOSITORY /mnt

# Alternative run, if server says "Connection closed by remote host. Is borg working on the server?" but borg is definitely installed at the target server. 
#borg mount --remote-path /usr/local/bin/borg $REPOSITORY /mnt

echo "You can find your backups in /mnt. To copy files execute e.g. 'cp -ra /mnt/1970-01-01/var/* /var'"
echo "Please don't forget to umount your backups with '~/umount_backup.sh' afterwards."
```

```bash
#!/bin/bash

borg umount /mnt
```

## How to restore a complete server

```bash
# Start on a fresh server as root
apt update && apt dist-upgrade
apt install borgbackup
borg mount ssh://borg@1.2.3.4:22/~/backups/Server1 /mnt
cp /mnt/1970-01-01/root/installed-packages.txt /root/
xargs apt install <installed-packages.txt -y
reboot
borg mount ssh://borg@1.2.3.4:22/~/backups/Server1 /mnt
cp -ra /mnt/1970-01-01/var/* /var/
cp -ra /mnt/1970-01-01/etc/* /etc/
cp -ra /mnt/1970-01-01/opt/* /opt/
cp -ra /mnt/1970-01-01/home/* /home/
cp -ra /mnt/1970-01-01/root/* /root/
cp -ra /mnt/1970-01-01/var/* /var/
reboot
# Afterwards you have to renew the ssh certifcates at the backup server for the automatic backup
