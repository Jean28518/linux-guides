# Matrix-Synapse auf Ubuntu 22.04 Server installieren

## Synapse installieren:
https://matrix-org.github.io/synapse/latest/setup/installation.html

```bash
sudo apt install -y lsb-release wget apt-transport-https
sudo wget -O /usr/share/keyrings/matrix-org-archive-keyring.gpg https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/matrix-org-archive-keyring.gpg] https://packages.matrix.org/debian/ $(lsb_release -cs) main" |
    sudo tee /etc/apt/sources.list.d/matrix-org.list
sudo apt update
sudo apt install matrix-synapse-py3
```

## Postgresql installieren
```bash
sudo apt install postgresql-14
```
in der config von postgresql den host auf localhost gesetzt (Kommentar entfernt)

<https://matrix-org.github.io/synapse/latest/postgres.html>
```bash
apt install libpq5
```
homeserver.yaml angepasst bzgl database

pg-hba.conf: folgendes hinzugefügt
```
local   synapse		synapse_user				scram-sha-256
```

## Caddy installiert
<https://caddyserver.com/docs/install#debian-ubuntu-raspbian>

Caddfile:
```
server.linuxguides.de {
  reverse_proxy /_matrix/* localhost:8008
  reverse_proxy /_synapse/client/* localhost:8008
  reverse_proxy localhost:8008
}

server.linuxguides.de:8448 {
  reverse_proxy localhost:8008
}
```


## Alles neu starten (und starten)


## User hinzufügen
```bash
register_new_matrix_user -u benuzter -c /etc/matrix-synapse/homeserver.yaml -a https://my.domain.com
```
