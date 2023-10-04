# ONLYOFFICE for Nextcloud

```bash
sudo -i
cd && mkdir onlyoffice && cd onlyoffice && vim run.sh

# Add:
docker run -i -t -d -p 10923:80 --restart=unless-stopped \
    --name onlyoffice -e JWT_ENABLED='true' -e JWT_SECRET='Ohgeaf6scha7Iu9U' onlyoffice/documentserver


bash run.sh
# 1 minutes after start of the container (if you are using local https)
docker exec onlyoffice sed -i 's/"rejectUnauthorized": true/"rejectUnauthorized": false/g' /etc/onlyoffice/documentserver/default.json
docker restart onlyoffice
```

## Caddfile

```Caddyfile
onlyoffice.int.de {
    header {
        X-Forwarded-Proto: https;
        access-control-allow-origin: *;
    }
    root * /var/www/cert/
    reverse_proxy http://localhost:10923
}
```

Why the headers? -> look here: <https://github.com/ONLYOFFICE/onlyoffice-nextcloud/issues/664#issuecomment-1454938212>

## How to configure in Nectcloud

- Deactivate and remove Nextcloud Office
- Install ONLYOFFICE
- In the administration settings go to OnlyOffice and enter the adress and the password `Ohgeaf6scha7Iu9U` (The start of the docker container takes about 1 min)
- Disable document preview in the "OnlyOffice" Settings of Nextcloud (Don't forget to hit 'save' in the bottom of "editor settings"
