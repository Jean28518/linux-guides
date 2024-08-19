# Open Project

https://www.openproject.org/de/docs/installation-and-operations/installation/docker/#one-container-per-process-recommended

(Copy the .env.example to .env)
```bash
TAG=14-slim
OPENPROJECT_HTTPS=true
OPENPROJECT_HOST__NAME=openproject.int.de
PORT=127.0.0.1:8080
OPENPROJECT_RAILS__RELATIVE__URL__ROOT=
IMAP_ENABLED=false
DATABASE_URL=postgres://postgres:p4ssw0rd@db/openproject?pool=20&encoding=unicode&reconnect=true
RAILS_MIN_THREADS=4
RAILS_MAX_THREADS=16
PGDATA="/var/lib/postgresql/data"
OPDATA="/var/openproject/assets"
PORT=19824
```
