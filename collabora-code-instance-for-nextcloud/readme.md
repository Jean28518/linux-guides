# Setup Collabora CODE Document Server for nextcloud

In this we create a docker container and a reverse proxy.
Instructions from: <https://sdk.collaboraonline.com/docs/installation/CODE_Docker_image.html>

- Auf den Server als root einloggen und folgende Befehle ausführen:

```bash
apt update && apt upgrade
sudo apt install docker.io docker
cd && mkdir collabora && cd collabora && vim run.sh

# (https://sdk.collaboraonline.com/docs/installation/CODE_Docker_image.html)
# Der username und das passwort sind für die Admin-Konsole dann erreichbar unter: https://office.int.de/browser/dist/admin/admin.html
# Nur domains, die in einer aliasgroup sind, werden akzeptiert.  Wichtig ist bei den domains vor einem Punkt zwei '\' anzugeben.
# Wenn eine nextcloud unter mehreren domains erreichbar sein soll, trennt man die domains in der aliasgroup1 mit einem ','
# Also: aliasgroup1=https://cloud\\.int\\.de:443,https://my\\.int\\.de:443

# Insert

docker run -t -d -p 9980:9980 -e "aliasgroup1=https://cloud\\.int\\.de:443" -e "username=admin" -e "password=eeJ0beil" --restart unless-stopped --name collabora collabora/code:latest


bash run.sh
```

## Caddy Reverse Proxy

```caddyfile
office.int.de {
  encode gzip
  reverse_proxy https://127.0.0.1:9980 {
    transport http {
      tls_insecure_skip_verify
    }
  }
}
```

## Nginx Reverse Proxy

```bash
sudo apt install certbot nginx
certbot certonly
```

- (1: Spin up a temporary webserver)
- E-Mail angeben
- ...
- Domain: bspw. 'office.int.de' angeben

`vim /etc/nginx/nginx.conf`

Dann folgendes eintragen, und `office.int.de` mit der eigenen domain ersetzen

```nginx
http {
    server {
     listen       443 ssl;
     server_name  office.int.de;


     ssl_certificate /etc/letsencrypt/live/office.int.de/fullchain.pem;
     ssl_certificate_key /etc/letsencrypt/live/office.int.de/privkey.pem;


     # static files
     location ^~ /browser {
       proxy_pass https://127.0.0.1:9980;
       proxy_set_header Host $http_host;
     }


     # WOPI discovery URL
     location ^~ /hosting/discovery {
       proxy_pass https://127.0.0.1:9980;
       proxy_set_header Host $http_host;
     }


     # Capabilities
     location ^~ /hosting/capabilities {
       proxy_pass https://127.0.0.1:9980;
       proxy_set_header Host $http_host;
     }


     # main websocket
     location ~ ^/cool/(.*)/ws$ {
       proxy_pass https://127.0.0.1:9980;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection "Upgrade";
       proxy_set_header Host $http_host;
       proxy_read_timeout 36000s;
     }


     # download, presentation and image upload
     location ~ ^/(c|l)ool {
       proxy_pass https://127.0.0.1:9980;
       proxy_set_header Host $http_host;
     }


     # Admin Console websocket
     location ^~ /cool/adminws {
       proxy_pass https://127.0.0.1:9980;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection "Upgrade";
       proxy_set_header Host $http_host;
       proxy_read_timeout 36000s;
     }
    }
}
```

`systemctl restart nginx`

In der Nextcloud den integrierten CODE Server deinstallieren \
Dann "Nextcloud Office" installieren, und in den Einstellungen unter: Nextcloud Office:

- `Verwenden Sie Ihren eigenen Server` auswählen
- folgende Adresse eintragen:`https://office.int.de`

## Verbindungsprobleme?

- Wenn sich die DNS-Einstellung geändert hat, kann dies bis zu einem Tag dauern, bis der neue Server wieder von Storage Share erreichbar ist
- Verbindungstest schlägt immer noch fehl? Dann kann Collabora nicht erreicht werden
- Verbingungstest ist grün, dennoch laden keine Dokumente? \
    Sichergehen, dass beim Starten des Docker-Containers die aliasgroup1 richtig definiert wurde. Ansonsten den log des docker containers ansehen: `docker logs CONTAINERID`

### Erklärung aliasgroup

Nur domains, die in einer aliasgroup sind, werden akzeptiert.  Wichtig ist bei den domains vor einem Punkt zwei '\' anzugeben.
Wenn eine nextcloud unter mehreren domains erreichbar sein soll, trennt man die domains in der aliasgroup1 mit einem ','
Also bspw heißt dann das docker Befehlsstück am Ende:

```bash
-e "aliasgroup1=https://cloud\\.int\\.de:443,https://my\\.int\\.de:443"
```

### Admin Konsole Collabora

- URL: <https://office.int.de/browser/dist/admin/admin.html>

## How to update

```bash
docker ps # Get ID of container
docker stop ID
docker rm ID
bash run.sh
```
