# Vaultwarden with docker

```bash
cd && mkdir vailtwarden && cd vaultwarden && vim docker-compose.yml

# Insert:
version: "2.1"
services: 
  vaultwarden: 
    image: "vaultwarden/server:1.28.1" 
    ports: 
      - "14623:80"
    restart: unless-stopped
    volumes: 
      - "./vw-data:/data"


docker-compose up -d
```

Update the number to the latest version here: <https://hub.docker.com/r/vaultwarden/server/tags>

## Caddyfile

```caddyfile
DOMAIN {
  reverse_proxy localhost:14623
}
```
