# Mattermost server with docker

We will install it with caddy as reverse proxy.

Instructions from: <https://mattermost.com/deploy/>

```bash
sudo apt install git vim
git clone https://github.com/mattermost/docker && mv docker mattermost && cd mattermost
cp env.example .env
vim .env
# Change the Domain (this should be enough for us)
# Also currently you need to manually replace the uesed variables. 
# I think that's currently a bug that mattermost doesn't translate bash variables in bash variables..

mkdir -p ./volumes/app/mattermost/{config,data,logs,plugins,client/plugins,bleve-indexes} && sudo chown -R 2000:2000 ./volumes/app/mattermost

sudo docker-compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d
```

## Caddy reverse proxy configuration

Super easy..

```Caddyfile
mm.int.de {
  reverse_proxy localhost:8065
}
```

## How to update mattermost

```bash
sudo docker-compose -f docker-compose.yml -f docker-compose.without-nginx.yml down

vim .env
# change the version tag in the .env file to the newest. 
# Example: 7.9
# You can find the newest tag here: https://hub.docker.com/r/mattermost/mattermost-team-edition/tags
sudo docker-compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d
```
