# Linkstack with Docker

From: <https://linkstack.org/docker/>

```bash
cd && mkdir linkstack && cd linkstack && vim run.sh
# Paste:
docker run --detach \
    --name linkstack \
    --publish 24105:80 \
    --restart unless-stopped \
    --mount source=linkstack,target=/htdocs \
    linkstackorg/linkstack

bash run.sh
```

## Caddyfile

```yaml
DOMAIN {
    reverse_proxy localhost:24105
}
```
