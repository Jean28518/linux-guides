# ToDos for a debian or ubuntu server after installation:


```
# Login and become root:

apt update && apt dist-upgrade -y

# Install required software
apt install vim ncdu openssh-server fail2ban

# Firewall
apt install ufw 
ufw allow ssh
ufw enable

# Automatic Updates:
apt install unattended-upgrades apt-listchanges
dpkg-reconfigure -plow unattended-upgrades
```