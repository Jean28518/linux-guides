# Implement basic security hardening for debian server

## Install basic packages

```bash
sudo apt update && sudo apt dist-upgrade -y && sudo apt install vim ufw ncdu htop git pwgen curl unzip psmisc -y
```

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
PubkeyAuthentication yes
```

## Install fail2ban
```bash
sudo apt install fail2ban -y && echo "sshd_backend = systemd" >> /etc/fail2ban/paths-debian.conf && sudo systemctl restart fail2ban
```

## Setup unattended upgrades:
```bash
sudo apt install unattended-upgrades apt-listchanges -y && sudo dpkg-reconfigure -plow unattended-upgrades
```

## Setup firewall
```bash
sudo ufw allow ssh
sudo ufw allow # The ports/services which should be accesible from the outside
sudo ufw enable
```

## Setup automatic restart
```bash
sudo crontab -e
50 1 * * 0 reboot # sunday at 1:50 am

# Or
50 1 * * * reboot # daily at 1:50 am

```

## Set log limit:

```
sudo echo "SystemMaxUse=1G" >> /etc/systemd/journald.conf && sudo systemctl restart systemd-journald.service
```

## Setup automatic backup system
<https://github.com/Jean28518/linux-guides/tree/main/backup-server-sytem>


