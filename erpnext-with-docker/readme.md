# ERP Next

<https://hub.docker.com/r/frappe/erpnext/tags>

```bash
git clone https://github.com/frappe/frappe_docker.git && mv frappe_docker erp-next && cd erp-next && vim pwd.yml
# Change Port 8080 to 29323 in the frontend service
# The rest should be fine.
# Change all restart policies to:
#     restart: unless-stopped
docker-compose -f pwd.yml up -d
```

## Caddyfile

```Caddyfile
erp.int.de {
  reverse_proxy localhost:29323
}
```

## Access

- Wait for about 5 to 10 Minutes.
- Access your instance via webbrowser.
- Your first login is:
  - Username: `Administrator`
  - Password: `admin`

## How to backup and restore

### ERPNext has error after upgrade?

```bash
docker ps # Take ID from erp-next_backend_1
docker exec -it #ID# bash -l
/usr/local/bin/bench migrate
exit
```

### Backup

```bash
sudo -i
docker ps # Take ID from erp-next_backend_1
docker exec -it #ID# bash -l
/usr/local/bin/bench --verbose --site all backup --with-files
exit
cd && mkdir "backup_erp_$(date +'%Y-%m-%d_%H-%M-%S')" && mv /var/lib/docker/volumes/erp-next_sites/_data/frontend/private/backups/* "backup_erp_$(date +'%Y-%m-%d_%H-%M-%S')/"
```

### Restore

```bash
sudo -i
# Change into folder where backed up files are

cp -a * /var/lib/docker/volumes/erp-next_sites/_data/frontend/private/backups/
docker ps # Take ID from erp-next_backend_1
docker exec -it #ID# bash -l
/usr/local/bin/bench --force restore sites/frontend/private/backups/DATE_TIME-frontend-database.sql.gz --with-private-files sites/frontend/private/backups/DATE_TIME-frontend-private-files.tar --with-public-files sites/frontend/private/backups/DATE_TIME-frontend-files.tar
# MySQL Password is: admin
/usr/local/bin/bench migrate
exit
```
