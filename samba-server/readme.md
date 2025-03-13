# Setup Samba Server for Windows and Linux Filesystem Share

## Server
```bash
# Become root
apt install samba

# Prepare Storage space:
mkdir /var/samba
chmod 777 /var/samba

cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

vim /etc/samba/smb.conf
```

**Content of smb.conf:** \
Configures a public file server at /media/samba/.
```
[global]
workgroup = Fileserver
security = user
map to guest = Bad Password

[homes]
comment = Home Directories
browsable = no
read only = no
create mode = 0750

[public]
path = /var/samba
public = yes
writable = yes
comment = Fileserver
printable = no
guest ok = yes

# For a specific user "laser" inside
[laser-jobs]
path = /data/samba_fs/laser-jobs 
read only = no
writeable = yes
browseable = yes
valid users = laser
create mask = 0644
directory mask = 0755
; if you set this, all files get written as this user
    #    force user = laser
```

```bash
# For the laser-jobs
sudo smbpasswd -a laser
sudo chown -R laser:laser /data/samba_fs/laser-jobs 

systemctl restart smbd.service samba*
ufw allow 445
```

### Add user

Samba seems to have their own user management with password database

```bash
sudo smbpasswd -a USERNAME
```

## Linux Client:
### Nautilus:
- select 'other' in the left bar
- type `smb://IP-ADDRESS/public` into the server connection field
- click on connect, and choose 'anoynmus'

### Nemo:
- choose 'File -> connect with server'
- choose 'windows share'
- enter the ip adress of the fileserver into the server field
- leave 'release' blank
- as folder enter `/public`
- click on 'Connect'
- as username enter `nobody`
- enter e.g. `x` into the password field. It is completely up to you what to choose.
- finally click again on 'Connect'

### Mount
```bash
sudo apt install cifs-utils -y

# These two // in front of the ip address are correct and essential
sudo mount -t cifs //IP-ADDRESS/public /mnt -o user=nobody
# Leave password empty and just press enter
```

## Windows Client:
- Open explorer
- rightclick network on the left side, select 'mount network filesystem'
- write `\\IP-ADDRESS\public` into the text field and choose a network character, e.g. 'Z'
