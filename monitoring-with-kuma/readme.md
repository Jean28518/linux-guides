# Monitoring with Uptime Kuma

<https://hub.docker.com/r/louislam/uptime-kuma/tags>

```bash
cd && mkdir uptime-kuma && cd uptime-kuma && vim run.sh

# Insert
docker run -d --restart=unless-stopped -p 20623:3001 -v ./uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma:1

bash run.sh
```

## Caddyfile

```Caddyfile
kuma.int.de {
  #tls internal
  reverse_proxy localhost:20623
}
```
