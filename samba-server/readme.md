# Setup Samba Server for Windows and Linux Filesystem Share

## Server
```bash
# Become root
apt install samba

# Prepare Storage space:
mkdir /media/samba/
chmod 777 /media/samba/

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
path = /media/samba/
public = yes
writable = yes
comment = Fileserver
printable = no
guest ok = yes
```

```bash
systemctl restart smbd.service
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
