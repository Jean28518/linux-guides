# Cinny

Yet another matrix client. At the current time only in english.

```bash
vim docker-compose.yml
version: "3.7"
services:
  cinny:
    container_name: cinny
    image: ajbura/cinny:latest
    restart: unless-stopped
    ports:
      - 50224:80


docker-compose up -d


docker cp cinny:/app/config.json ./config.json
vim config.json
{
  "defaultHomeserver": 0,
  "homeserverList": [
    "matrix.int.de"
  ],
  "allowCustomHomeservers": false
}
docker cp ./config.json cinny:/app/config.json

docker-compose restart



```
