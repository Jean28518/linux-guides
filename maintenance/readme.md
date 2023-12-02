# Maintenance

```bash
# Check current processes and resource usage
htop

# Check available diskspace
df -h

# Check RAID Status
cat /proc/mdstat

## CHECK, IF ENOUGH DISKSPACE IS AVAILABLE!

# Check, if the backups are working
sudo -i
cd
./mount_backup.sh
ls /mnt/
./umount_backup.sh
# Check the diskspace of the backup server

## ONLY RESUME IF A GOOD BACKUP IS AVAILABLE!
## (Because updates can have high fail potential)

# Check, if the firewall is working and if all open ports are for a service
ufw status numbered
ss -tlpn
ufw delete NUMBER && ufw status numbered
# Note every service which could be upgradeable seperately!!

# Some ports explained:
# - 389: LDAP
# - 636: LDAPS
# - 88: Kerberos
# - 464: kpasswd (used by FreeIPA)
# - 10000: Jitsi UDP?

# Update the machine
apt update && apt dist-upgrade

# Check the current OS Version:
cat /etc/os-release

# Check every service for updates and remove unused ones.
docker ps
podman ps
snap list
pstree
# Any PHP sites ?
# Nextcloud:
# Check for big updates
# Check for app updates
# Are all apps really used?


# Check the caddy file for active services:
vim /etc/caddy/Caddyfile

# Free diskspace:
docker image prune -a
podman system prune --all
apt autoremove
apt clean
ncdu /

# Check all accesses - Are there old users on the services we could delete?
# - on linux
# - on nextcloud
# - on all docker services

reboot
```

**Check in the end the basic security of the server:**
<https://github.com/Jean28518/linux-guides/tree/main/basic-security-for-server>

**Set next appointment for maintenance check!**

## Update your documentation accordinly

- All Versions of installed software
- Ensure that every software is documented and all old entries got deleted
- Update the basic information about the server
