# ERP Next

<https://hub.docker.com/r/frappe/erpnext/tags>

```bash
cd && git clone https://github.com/frappe/frappe_docker.git && mv frappe_docker erp-next && cd erp-next && vim pwd.yml
# Change Port 8080 to 29323 in the frontend service
# The rest should be fine.
# Change all restart policies unless-stopped (at the best in the graphical text editor) to:
#     restart: unless-stopped
docker compose -f pwd.yml up -d
```

### Test instance

```bash
git clone https://github.com/frappe/frappe_docker.git && mv frappe_docker erp-next-test && cd erp-next-test && vim pwd.yml
# Change Port 8080 to 29324 in the frontend service
# The rest should be fine.
# Change all restart policies unless-stopped (at the best in the graphical text editor) to:
#     restart: unless-stopped
docker compose -f pwd.yml up -d
```

## Caddyfile

```Caddyfile
erp.int.de {
  reverse_proxy localhost:29323
}

erptest.int.de {
  reverse_proxy localhost:29324
}
```

## Access

- Wait for about 5 to 10 Minutes.
- Access your instance via webbrowser.
- Your first login is:
  - Username: `Administrator`
  - Password: `admin`

## How to install additional Modules

```bash
docker compose -f pwd.yml exec backend bash
bench get-app https://github.com/alyf-de/erpnext_germany.git
bench --site frontend install-app erpnext_germany
exit
docker compose -f pwd.yml restart
```

## How to backup and restore

### ERPNext has error after upgrade?

```bash
docker compose -f pwd.yml stop
docker compose -f pwd.yml start
docker compose -f pwd.yml exec backend bench --site frontend migrate
docker compose -f pwd.yml exec backend bench build
```

### CSS Errors:

```bash
docker compose -f pwd.yml down
# The names of the volumes could be different.
docker volume rm erpnext_redis-cache-data erpnext_redis-queue-data
docker compose -f pwd.yml up -d
```

### Backup

```bash
sudo -i
docker compose -f pwd.yml exec backend bash
/usr/local/bin/bench --verbose --site all backup --with-files
exit
cd && mkdir "backup_erp_$(date +'%Y-%m-%d_%H-%M-%S')" && mv /var/lib/docker/volumes/erp-next_sites/_data/frontend/private/backups/* "backup_erp_$(date +'%Y-%m-%d_%H-%M-%S')/"
```

### Restore

```bash
sudo -i
# Change into folder where backed up files are

cp -a * /var/lib/docker/volumes/erp-next_sites/_data/frontend/private/backups/
docker compose exec backend bash
/usr/local/bin/bench --force restore sites/frontend/private/backups/DATE_TIME-frontend-database.sql.gz --with-private-files sites/frontend/private/backups/DATE_TIME-frontend-private-files.tar --with-public-files sites/frontend/private/backups/DATE_TIME-frontend-files.tar
# MySQL Password is: admin
/usr/local/bin/bench migrate
exit
```

## Errors?

```bash
docker compose -f pwd.yml exec backend bench --site frontend migrate

```

## Update

- Start with the update of the test instance
- Update the tag of all images in `pwd.yml` to the latest one. (In vim you can do this with the command: `:%s/OLDTAG/NEWTAG/gc`)
```bash
docker compose -f pwd.yml pull
docker compose -f pwd.yml up -d
```

### Problems?

Try to clear cache inside the backend container:

```bash
bench clear-cache
bench clear-website-cache
```
