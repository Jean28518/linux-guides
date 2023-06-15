# Maintenance

```bash
# Check, if the backups are working
sudo -i
cd
./mount-backups.sh
ls /mnt/
./ummount-backups.sh

# Check, if the firewall is working and if all open ports are for a service
ufw status numbered
netstat -tulpn | grep PORT
ufw delete NUMBER
# Note every service which could be upgradeable seperately!!

# Update the machine
sudo apt dist-upgrade

# Check the current OS Version:
cat /etc/os-release

# Check every service for updates and remove unused ones.
netstat-tulpn
docker ps
podman ps

# Check the caddy file for active services:
vim /etc/caddy/Caddyfile

reboot
```

**Check in the end the basic security of the server:**
<https://github.com/Jean28518/linux-guides/tree/main/basic-security-for-server>

**Set next appointment for maintenance check!**
