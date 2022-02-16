# Video

<https://youtu.be/7ZgjElyUqZ4>

# Vorbereitungen: 

* Debian oder Ubuntu Server als BackUp Server einrichten
* Am besten diesen Server bei einem anderen Serveranbieter mieten, oder bei sich Zuhause haben. Auf jeden Fall an einem anderen pyhsischen Ort.

# Source Server:

```
ssh-keygen
less ~/.ssh/id_rsa.pub
```

# BackUp Server:

```
sudo adduser serverbackup # Keine Root Rechte!

su serverbackup
mkdir .ssh && nano ~/.ssh/authorized_keys

sudo nano ~/.ssh/authorized_keys # Den Public key vom Source Server hinzufügen
command="borg serve --restrict-to-path /home/serverbackup/backups/Server --append-only" # Das vor dem eben eingefügten Public Key einfügen

sudo apt install borgbackup
mkdir -p ~/backups/Server1

borg init --encryption=repokey ~/backups/Server1
borg key export ~/backups/Server1 ~/key-export # Diesen Schlüssel sicher aufbewahren und die Datei danach vom Server löschen.
```

# Source Serer:

```
sudo apt install borgbackup -y
nano ~/backup.sh
    #!/bin/bash        
    DATE=`date +"%Y-%m-%d"`
    REPOSITORY="ssh://serverbackup@1.2.3.4:22/~/backups/Server1"
    export BORG_PASSPHRASE="MeineSuperSicherePassphrase"
    borg create $REPOSITORY::$DATE /home/jean /var/www --exclude-caches
   
chmod +x /backup.sh
~/backup.sh # Austesten

crontab -e
0 2 * * * /home/jean/backup.sh # Jeden Tag um 2:00 Uhr
```

# Backup Server

```
nano ~/prune-backup.sh

    #!/bin/bash
    export BORG_PASSPHRASE="MeineSuperSicherePassphrase"
    borg prune -v ~/backups/Server1 \
        --keep-daily=10 \
        --keep-weekly=6 \
        --keep-monthly=12
chmod +x ~/prune-backup.sh # Austesten

crontab -e
0 9 * * * /home/serverbackup/prune-backup.sh # Jeden Tag um 9:00 Uhr
```
