# Libre Workspace Migration/Recovery

This is an example how to restore libre workspace from a backup and/or sync data from an "old" instance to a "new" instance.
Ip address changes are handled, domain changes are not handled in this example

```bash
apt install tmux -y
tmux
export BORG_REPO=ssh://user@mybackupserver:22/./server1
export BORG_PASSPHRASE=xxxxxxxxxxxxxxxxxxxxxxxxxxx
RECOVERY_DATE=1970-01-01

# Stop all Services on new Libre Workspaces:
sudo systemctl stop mariadb caddy libre-workspace-portal libre-workspace-service redis postfix docker samba-ad-dc

# Remove the /var/lib/mysql/ because when differnet nextcloud versions existed this would break otherwise.
rm -r /var/lib/mysql/
rm -r /var/www/nextcloud

cd /  # CRITICAL!!!!
sudo borg extract --list --numeric-ids $BORG_REPO::$RECOVERY_DATE-data
# Its pretty normal that you have to insert the password again

cd / # CRITICAL!!!
sudo borg extract --list --numeric-ids $BORG_REPO::$RECOVERY_DATE-system var/lib/libre-workspace/portal/installed-packages.txt
sudo borg extract --list --numeric-ids \
  --exclude 'etc/fstab' \
  --exclude 'etc/netplan/*' \
  --exclude 'etc/network/*' \
  $BORG_REPO::$RECOVERY_DATE-system etc
sudo apt update
sudo apt install </var/lib/libre-workspace/portal/installed-packages.txt

sudo borg extract --list --numeric-ids \
  --exclude 'dev/*' \
  --exclude 'proc/*' \
  --exclude 'sys/*' \
  --exclude 'tmp/*' \
  --exclude 'run/*' \
  --exclude 'mnt/*' \
  --exclude 'media/*' \
  --exclude 'bin/*' \
  --exclude 'boot/*' \
  --exclude 'sbin/*' \
  $BORG_REPO::$RECOVERY_DATE-system
  

## IF WE WANNA DO A 'LIVE' MIGRATION (othersise skip this part)
# VERY IMPORTANT THAT WE DO THAT DIRECTLY AFTER THE REBOOT OTHERWISE WE GET AN BACKUP CONFLICT
sudo systemctl stop mariadb caddy libre-workspace-portal libre-workspace-service redis postfix docker samba-ad-dc

# Stop also the services on the old server
OLDSERVER=1.2.3.4
ssh -t root@$OLDSERVER "systemctl stop mariadb caddy libre-workspace-portal libre-workspace-service redis postfix docker samba-ad-dc"

# NOW YOU CAN SWITCH THE DNS ENTRIES!  

cd /
sudo rsync -aAXPh --numeric-ids --info=progress2 -e ssh \
  --exclude='/etc/fstab' \
  --exclude='/etc/netplan/' \
  --exclude='/etc/network/' \
  --exclude='/dev/*' \
  --exclude='/proc/*' \
  --exclude='/sys/*' \
  --exclude='/tmp/*' \
  --exclude='/run/*' \
  --exclude='/mnt/*' \
  --exclude='/media/*' \
  --exclude='/bin/*' \
  --exclude='/boot/*' \
  --exclude='/sbin/*' \
  root@$OLDSERVER:/ /
  
ssh -t root@$OLDSERVER "shutdown now"

## END LIVE MIGRATION, continue down:

# DOCKER SANITIZATION (Split-Brain Prevention)
echo "Cleaning Docker engine state to prevent kernel desync..."
sudo systemctl stop docker docker.socket containerd
sudo rm -rf /var/lib/docker/overlay2/*
sudo rm -rf /var/lib/docker/containers/*
sudo rm -rf /var/lib/docker/network/*
sudo rm -rf /var/lib/docker/image/*
sudo rm -rf /var/lib/docker/buildkit/*
sudo rm -rf /var/lib/docker/runtimes/*
sudo rm -rf /var/lib/docker/swarm/*
sudo rm -rf /var/lib/docker/tmp/*
  
sudo apt update
sudo apt full-upgrade
sudo update-initramfs -u -k all
# Grub install and update is very important
lsblk
sudo grub-install /dev/sdx
sudo update-grub

# Do some adjustments for the integration into libre workspace cloud ...
# ...
libre-workspace-config-tool --file-type rc set /etc/libre-workspace/portal/portal.conf RUNNING_IN_CLOUD True
# ...

ip a

# Change IP Address for Libre Workspace
NEW_IP=2.3.4.5
find /root/ -mindepth 2 -maxdepth 2 -type f -exec sed -i "s/$OLDSERVER/$NEW_IP/g" {} + 2>/dev/null
. /var/lib/libre-workspace/portal/venv/bin/activate
cd /usr/lib/libre-workspace/portal/
python3 manage.py shell -c "import unix.unix_scripts.unix; unix.unix_scripts.unix.change_ip('$NEW_IP')"

sudo reboot


# Restart Docker containers in every subdirectory of /root/
for dir in /root/*/; do
    # Only proceed if the directory contains a docker-compose file
    # (Handles both .yml and .yaml extensions)
    if [ -f "${dir}docker-compose.yml" ] || [ -f "${dir}docker-compose.yaml" ] || [ -f "${dir}compose.yml" ]; then
        echo "--> Processing Docker setup in: $dir"
        
        # Subshell or cd into the directory to run docker compose
        cd "$dir" || continue 
        
        docker compose down
        docker compose up -d
        
        # Return to the previous directory
        cd - > /dev/null
    fi
done
# If you have collabora and dont want to wait for the next update of collabora:
docker rm -f collabora
bash /root/collabora/run.sh

# Finished :)
```
