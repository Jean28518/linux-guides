# Implement basic security hardening for debian trixie server

## Install basic packages

```bash
sudo apt update && sudo apt full-upgrade -y && sudo apt install vim ufw ncdu htop git pwgen curl unzip psmisc fail2ban cron tree tmux -y
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
sudo apt install fail2ban
```

## Setup unattended upgrades:
```bash
sudo apt install unattended-upgrades apt-listchanges -y && sudo dpkg-reconfigure -plow unattended-upgrades
```

### Oneliner with automatic restarts of services and hourly unattended upgrades
```bash
sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades needrestart apt-listchanges && sudo bash -c 'printf "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\n" > /etc/apt/apt.conf.d/20auto-upgrades && mkdir -p /etc/needrestart/conf.d && printf "$nrconf{restart} = '\''a'\'';\n" > /etc/needrestart/conf.d/99-auto-restart.conf && mkdir -p /etc/systemd/system/apt-daily.timer.d /etc/systemd/system/apt-daily-upgrade.timer.d && printf "[Timer]\nOnCalendar=\nOnCalendar=hourly\nRandomizedDelaySec=30m\n" | tee /etc/systemd/system/apt-daily.timer.d/override.conf > /etc/systemd/system/apt-daily-upgrade.timer.d/override.conf && systemctl daemon-reload && systemctl restart apt-daily.timer apt-daily-upgrade.timer'
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

### Syslog Limit:

```bash
#!/bin/bash

# Define the log file to rotate
LOG_FILE="/var/log/syslog"

# Define the logrotate configuration file path
LOGROTATE_CONF="/etc/logrotate.d/syslog_custom"

# Check if the log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' not found. Exiting."
    exit 1
fi

# Create the logrotate configuration
cat << EOF | sudo tee "$LOGROTATE_CONF" > /dev/null
$LOG_FILE {
    size 1G
    rotate 5
    compress
    delaycompress
    missingok
    notifempty
    daily
    create 0640 root adm
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
EOF

# Set appropriate permissions for the logrotate configuration file
sudo chmod 644 "$LOGROTATE_CONF"

echo "Logrotate configuration for '$LOG_FILE' has been set up successfully."
echo "Configuration file: '$LOGROTATE_CONF'"
echo "The syslog will now be rotated when it reaches 1GB in size."
echo "It will keep 5 compressed rotated logs. Logrotate will run every daiy automatically."
echo "To test the configuration (without actually rotating unless needed), run: sudo logrotate -d $LOGROTATE_CONF"
echo "To run now logrotate, run: sudo logrotate -f $LOGROTATE_CONF"
```

## Setup automatic backup system
<https://github.com/Jean28518/linux-guides/tree/main/backup-server-sytem>


