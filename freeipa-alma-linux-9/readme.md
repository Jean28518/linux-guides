# FreeIPA

We will install it without DNS-Server-Module.

Start on a fresh Alma Linux 9 installation.

```bash
sudo hostnamectl set-hostname ipa.int.de
sudo vim /etc/hosts
# Insert an entry of your ip with ipa.int.de
# Example: 192.168.178.20 ipa.int.de

# Configure SELinux:
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
sestatus
sudo reboot

# Install FreeIPA:
sudo dnf install freeipa-server -y
sudo ipa-server-install
# Choose here the default except for the last question which is the confirmation. Choose yes here.
# The configuration process takes a long time (ca. 5 minutes)

# Configure Firewall:
sudo firewall-cmd --add-service={http,https,dns,ntp,freeipa-ldap,freeipa-ldaps} --permanent
sudo firewall-cmd --reload
```

Insert `192.168.178.20 ipa.int.de` into your DNS-Server.

You can then log in at the browser interface with "admin" and your set password.

## Configure Custom DNS-Server for Alma Linux

```bash
# Change enp0s3 to your specific connection name which you can see with 'ip a'
nmcli connection modify enp0s3 ipv4.dns "192.168.178.84 8.8.8.8"
service NetworkManager restart
```

## Add Linux Client to FreeIPA Server

Set a FQDN to the client via hostnamectl. The domain name should be in the same domain space like the freeipa server. In our example this is int.de.

```bash
sudo hostnamectl set-hostname client001.int.de

# Ensure that dns server holds the client address and the free-ipa-server and the linux client are beware of the client name.
# On the Client and on the freeIPA Server this has to work:
ping client001.int.de

# Install freeipa-client on the linux client:
sudo apt update
sudo apt install freeipa-client oddjob-mkhomedir
# In the Configuration:
# - confirm INT.DE
# leave the rest blank

# Make sure that the ipa server is reachable under ipa.int.de:
ping ipa.int.de
sudo ipa-client-install --hostname=`client001.int.de` --mkhomedir --server=ipa.int.de --domain int.de 
--realm INT.DE
# Type yes in the autodiscovery qeustion
# Type no in the ntp question
# Type yes in the confirmation question
# The user authorized to enroll computers: admin
# Password: Password of the freeipa admin.
sudo pam-auth-update
# Make sure that 'create home directory on login' is activated
```

### Disable user list on gdm

<https://help.gnome.org/admin/system-admin-guide/stable/login-userlist-disable.html.en>

Create two files:

```bash
sudo vim /etc/dconf/profile/gdm
# Insert:
user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults

sudo mkdir -p /etc/dconf/db/gdm.d/
sudo vim /etc/dconf/db/gdm.d/00-login-screen
# Insert:
[org/gnome/login-screen]
disable-user-list=true


# Update dconf:
sudo dconf update
```

### Issues

#### User sometimes is not able to log in because the FreeIPA server says "old password ..."

- Try to reset the password in the admin interface
- The user should log in to the ipa interface. There he is requested to change the password.

#### Computer got locked out because too many wrong password attempts

- Login as admin in the free ipa console, go to rules -> password rules
- Change max duration (days) to 0
- Changee min duration (hours) to 0
- Save
- Try to login at the computer again.

#### Give freeipa user(s) sudo rights on computer(s)

- Rules -> Sudo -> Sudo Rules
- Add a new rule
- You can leave sudo order, options blank.
- Add users or groups which should have sudo access
- Add hosts or host groups on which they should have sudo access
- You can select "every command" in the command sections
- you can leave "as who" to specific users groups while leaving the rest empty.
- save the rule and restart the clients.

##### Examples for a sudo command

Of course you can e.g. allow every user on every host to issue apt update.

```bash
/usr/local/bin/apt update
/bin/bash      # <- sudo -i
```

## Configure Nextcloud to use ldap of FreeIPA

- Create a new user in the FreeIPA Interface called 'nextcloudsysuser' and assign it to the groups admins and ipausers.

```bash
sudo apt install php-ldap
# Also restart php service
```

- Install the LDAP App in Nextcloud
- In the LDAP/AD Integration:
  - Server: ipa.int.de (localhost would also be fine)
  - Port: 389
  - User: uid=nextcloudsysuser,cn=users,cn=accounts,dc=int,dc=de
  - Password: pw nextcloudsysuser
  - Base DN: dc=int,dc=de
- In the Users Section of LDAP/AD Integration:
  - Expand the LDAP-Query and ensure: `(objectclass=*)`
- In the Login Attributes change nothing and click on next
- In the Groups tab expand the LDAP Query and ensure: `(|(cn=ipausers))`
- No go back to the Login Attributes and ensure the ldap query: `(&(objectclass=*)(uid=%uid))`
  - Click on next so we are back into the groups settings
- Click 'advanced' at the upper right corner
  - Under Folder/directory Settings ensure:
    - Base user tree: `cn=users,cn=accounts,dc=int,dc=de`
    - Group Display Name: `cn`
    - Base group tree: `cn=groups,cn=accounts,dc=int,dc=de`
    - Association between users and groups: Select 'uniqueMember'
  - Under Special Attributes:
    - email: `mail`
    - naming rule: `cn`
  - now click on 'test configuration'.
- You are finished!

*The user login may still not work. When this is the case for you, check the login credentials with the 'dc's in the end.*

## Configure Mattermost with LDAP

**Warning:** In tests this progress deleted all messages of existing users, which are named equally.

<https://docs.mattermost.com/configure/authentication-configuration-settings.html#ad-ldap>

- Create a new User `mattermostsysuser` in FreeIPA and assign him to ipausers and admins
- Switch to mattermost
- Go to system settings -> Authentication -> AD/LDAP
- AD/LDAP-Server: `ipa.int.de`
- AD/LDAP Port: 389
- Connection Security: STARTTLS
- Skip Certificate Test: True
- Bind username: `uid=mattermostsysuser,cn=users,cn=accounts,dc=int,dc=de`
- Bind password: password of the mattermostsysuser
- Base-DN: `dc=int,dc=de`
- User filter: `(objectclass=*)`
- Group filter: `(|(cn=ipausers))`
- Attribute ID: `uid`
- Attribute "Login ID": `uid`
- Attribute Username: `cn`
- E-Mail Attribute: `mail`
- Keep the rest blank and click on 'Sync AD/LDAP now' at the very bottom. This takes some seconds. Reload the page and check the status.
- You are finished!
