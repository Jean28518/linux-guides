# Monitoring with Uptime Kuma

<https://hub.docker.com/r/louislam/uptime-kuma/tags>

```bash
cd && mkdir uptime-kuma && cd uptime-kuma && vim run.sh
docker run -d --restart=unless-stopped -p 20623:3001 -v ./uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma:1
```

## Caddyfile

```Caddyfile
DOMAIN {
  #tls internal
  reverse_proxy localhost:20623
}
```
