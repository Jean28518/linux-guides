# Mattermost server with docker

We will install it with caddy as reverse proxy.

Instructions from: <https://mattermost.com/deploy/>

```bash
apt install git vim docker docker-compose
git clone https://github.com/mattermost/docker && cd docker
cp env.example .env
vim .env
# Change the Domain (this should be enough for us)

mkdir -p ./volumes/app/mattermost/{config,data,logs,plugins,client/plugins,bleve-indexes} && sudo chown -R 2000:2000 ./volumes/app/mattermost

sudo docker-compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d
```

## Caddy reverse proxy configuration
Super easy..
```
chat.int.de {
  reverse_proxy localhost:8065
}
```

## Connect to Nextcloud (wip):
<https://developers.mattermost.com/integrate/apps/authentication/oauth2/>
Insert the outh data into "connected account" in the admin settings.