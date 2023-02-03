# Implement basic security hardening for ubuntu server

## Add public key for ssh login
Run this command of your machine, from which you want to connect to the server
```bash
ssh-copy-id -i .ssh/id_rsa -p 22 USER@SERVERADRESS
ssh USER@SERVERADRESS
```

If you want to disable password authentication:
```bash
sudo vim /etc/ssh/sshd_config

# Ensure following line
PasswordAuthentication no
```

## Install fail2ban
```bash
sudo apt install fail2ban
```

## Setup unattended upgrades:
```bash
sudo apt install unattended-upgrades apt-listchanges
sudo dpkg-reconfigure -plow unattended-upgrades
```

## Setup firewall
```bash
sudo ufw allow ssh
sudo ufw allow # The ports/services which should be accesible from the outside
sudo ufw enable
```

## Setup automatic backup system
<https://github.com/Jean28518/linux-guides/tree/main/backup-server-sytem>

