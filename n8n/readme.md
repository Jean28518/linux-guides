# N8N

```bash
cd && mkdir n8n && cd n8n && vim run.sh

# Insert
docker run -d -it --rm --name n8n -p 5678:5678 -v ~/n8n/data:/home/node/.n8n docker.n8n.io/n8nio/n8n
```

## Caddy:

```Caddyfile
n8n.int.de {
  reverse_proxy localhost:5678
}
```
