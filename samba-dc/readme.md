# Samba as Domain Controller

```bash
sudo -i
hostnamectl set-hostname la

echo "192.168.178.57 la.int.de la" >> /etc/hosts # IP of the server itself

# Only on ubuntu:
systemctl disable --now systemd-resolved
unlink /etc/resolv.conf

# Make sure you are not running any dns server 
sudo apt purge dnsmasq

vim /etc/resolv.conf
# Samba server IP address
nameserver 192.168.178.57

# fallback resolver
nameserver 208.67.222.222

# main domain for Samba
search int.de

# Make /etc/resolv.conf immutable because the system sometimes overwrites it.
sudo chattr +i /etc/resolv.conf
apt update && apt install -y acl attr samba samba-dsdb-modules samba-vfs-modules smbclient winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user dnsutils chrony net-tools
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
# Administrator password: Gae7Eexo

mv /etc/krb5.conf /etc/krb5.conf.orig
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

systemctl start samba-ad-dc

samba-tool domain passwordsettings set --complexity=off
samba-tool domain passwordsettings set --history-length=0
samba-tool domain passwordsettings set --min-pwd-age=0
samba-tool domain passwordsettings set --max-pwd-age=0
```

## Usermanagement

```bash
sudo samba-tool user create USERNAME

sudo samba-tool user edit USERNAME
# Add for example the "mail" attribute

sudo samba-tool user list
sudo samba-tool user show USERNAME
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