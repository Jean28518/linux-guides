# Jitsi with docker

Guide from: <https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker/>

<https://github.com/jitsi/docker-jitsi-meet/releases/latest>

```bash
cd
wget https://github.com/jitsi/docker-jitsi-meet/archive/refs/tags/stable-####.zip # Get the latest reelease zip archive
unzip stable-####.zip
mv docker-jitsi-meet-stable-#### jitsi
cd jitsi

cp env.example .env
vim .env 
# Change HTTP_PORT to 30323
# Comment out HTTPS_PORT
# Comment out the PUBLIC_URL and change it to e.g. https://meet.int.de

vim docker-compose.yml
# Comment out the Port 443
# Comment out all expose ports from the xmpp server
# Comment out the Port expose 8080 at the videobridge

./gen-passwords.sh

mkdir -p ~/.jitsi-meet-cfg/{web,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}

docker-compose up -d # Do not use sudo here or execute the mkdir command also with sudo.

sudo ufw allow 10000/udp

# Make sure your revers proxy supports websockets (in nginx proxy manager you have to enable this at the entry)
```

## Caddy configuration

```Caddyfile
meet.int.de {
    reverse_proxy localhost:30323
}
```

## How to update

Latest tag:
<https://github.com/jitsi/docker-jitsi-meet/releases/latest>

```bash
vim .env
# Set JITSI_IMAGE_VERSION at the very end to e.g. 'stable-8719'


docker-compose up -d
```
