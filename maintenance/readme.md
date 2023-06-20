# Maintenance

```bash
# Check available diskspace
df -h

## CHECK, IF ENOUGH DISKSPACE IS AVAILABLE!

# Check, if the backups are working
sudo -i
cd
./mount_backup.sh
ls /mnt/
./umount_backup.sh

## ONLY RESUME IF A GOOD BACKUP IS AVAILABLE!
## (Because updates can have high fail potential)

# Check, if the firewall is working and if all open ports are for a service
ufw status numbered
netstat -tulpn | grep PORT
ufw delete NUMBER && ufw status numbered
# Note every service which could be upgradeable seperately!!

# Some ports explained:
# - 389: LDAP
# - 636: LDAPS
# - 88: Kerberos
# - 464: kpasswd (used by FreeIPA)
# - 10000: Jitsi UDP?

# Update the machine
sudo apt dist-upgrade

# Check the current OS Version:
cat /etc/os-release

# Check every service for updates and remove unused ones.
netstat-tulpn
docker ps
podman ps
# - Any PHP sites like Nextcloud ?

# Check the caddy file for active services:
vim /etc/caddy/Caddyfile

# Free diskspace:
docker image prune -a
podman system prune --all
apt clean
ncdu /

reboot
```

**Check in the end the basic security of the server:**
<https://github.com/Jean28518/linux-guides/tree/main/basic-security-for-server>

**Set next appointment for maintenance check!**

## Update your documentation accordinly

- All Versions of installed software
- Ensure that every software is documented and all old entries got deleted
- Update the basic information about the server