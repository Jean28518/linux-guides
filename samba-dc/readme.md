# Samba as Domain Controller

Inspired by <https://www.considerednormal.com/2022/11/samba-based-active-directory-on-ubuntu-22-04/>

Chrony is not configured in this example.

```bash
sudo -i
hostnamectl set-hostname la

echo "192.168.178.57 la.int.de la" >> /etc/hosts # IP of the server itself

# Only on ubuntu:
systemctl disable --now systemd-resolved
unlink /etc/resolv.conf

# Make sure you are not running any dns server 
sudo apt purge dnsmasq

chattr -i -a /etc/resolv.conf
vim /etc/resolv.conf
# Insert:
# Samba server IP address
nameserver 192.168.178.57
# fallback resolver
nameserver 208.67.222.222
# main domain for Samba
search int.de


# Make /etc/resolv.conf immutable because the system sometimes overwrites it.
sudo chattr +i /etc/resolv.conf
apt update && apt install -y acl attr samba samba-dsdb-modules samba-vfs-modules smbclient winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user dnsutils chrony net-tools samba-ad-provision
# Default Keberos Realm: INT.DE
# Kerberos Server for your realm: la.int.de
# Administrations server for your realm: la.int.de

systemctl disable --now smbd nmbd winbind
systemctl unmask samba-ad-dc
systemctl enable samba-ad-dc

mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
samba-tool domain provision
# Realm: INT.DE
# Domain: INT
# Server Role: dc
# Backend: SAMBA_INTERNAL
# DNS forwarder IP adress: 208.67.222.222
# Administrator password: Gae7Eexo # Or take a password without bash special characters!

mv /etc/krb5.conf /etc/krb5.conf.orig
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

systemctl start samba-ad-dc

samba-tool domain passwordsettings set --complexity=off
samba-tool domain passwordsettings set --history-length=0
samba-tool domain passwordsettings set --min-pwd-age=0
samba-tool domain passwordsettings set --max-pwd-age=0
```

## Enable ldaps

Currently they are self signed.

```bash
cd /etc/samba/tls/
openssl req -newkey rsa:2048 -keyout myKey.pem -nodes -x509 -days 3650 -out myCert.pem
chmod 600 myKey.pem
cp myCert.pem /var/www/cert/samba.crt

vim /etc/samba/smb.conf
# Add in [global]
        tls enabled  = yes
        tls keyfile  = /etc/samba/tls/myKey.pem
        tls certfile = /etc/samba/tls/myCert.pem
        tls cafile   =

systemctl restart samba-ad-dc.service 
ufw allow ldaps
```

### Test

```bash
LDAPTLS_REQCERT=never ldapsearch -x -H ldaps://la.int.de -b "dc=int,dc=de" -v
```

## Usermanagement

```bash
sudo samba-tool user create USERNAME

sudo samba-tool user edit USERNAME
# Add for example the "mail" attribute

sudo samba-tool user list
sudo samba-tool user show USERNAME

# Reset password
sudo samba-tool user setpassword USERNAME
```

## Add dns entry

<https://wiki.samba.org/index.php/DNS_Administration#Adding_new_records>

```bash
# Example to add chat.int.de DNS record
samba-tool dns add la.int.de int.de chat A 192.168.178.57 -U administrator
```

```bash
samba_dnsupdate --all-names
```

## Add different apps

### Add nextcloud

- Server: `ldaps://localhost` Port: 636
- Bind-DN `cn=Administrator,cn=users,dc=int,dc=de`
- Password
- Base-DN: dc=int,dc=de
- In tab "Advanced" enable "Disable SSL-Check"
- In tab "User": Custom LDAP-Request: `(objectclass=*)`
- In tab "Login Atttributes": Custom LDAP-Request: `(&(objectclass=*)(cn=%uid))`
- In tab "Groups": Custom LDAP-Request: `(|(cn=users))`
- In tab "Advanced":
  - Folder-Settings:
    - Base user tree: `cn=users,dc=int,dc=de`
    - Base group tree: `cn=groups,dc=int,dc=de`
  - Special Properties:
    - Mail field: `mail`

### Add Rocket.Chat

- LDAP-Host: IP-Adress of the server
- LDAP-Port: 636
- Authentification:
  - Enable
  - `cn=Administrator,cn=users,dc=int,dc=de`
  - Password
- Encryption
  - Encyption: SSL/LDAPS
  - Disable the certificate check
- Click on save
- Click on test connection
- In Usersearch:
  - Base-DN: `cn=users,dc=int,dc=de`
