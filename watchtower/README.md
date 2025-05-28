# Watchtower

To easily keep up to date your docker containers.

```bash
cd && mkdir watchtower && cd watchtower && vim docker-compose.yml
# Insert:
services:
  watchtower:
    image: containrrr/watchtower
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
     

docker compose up -d
```
