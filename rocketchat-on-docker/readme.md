# Rocket.Chat with docker

```bash
cd && mkdir rocket.chat && cd rocket.chat && vim docker-compose.yml

# Insert:
services:
  rocketchat:
    image: registry.rocket.chat/rocketchat/rocket.chat:5.4.4
    restart: unless-stopped
    environment:
      MONGO_URL: "mongodb://mongodb:27017/rocketchat?replicaSet=rs0"
      MONGO_OPLOG_URL: "mongodb://mongodb:27017/local?replicaSet=rs0"
      ROOT_URL: "https://chat.int.de"
      PORT: 3000
      DEPLOY_METHOD: "docker"
    depends_on:
      - mongodb
    ports:
      - 18423:3000

  mongodb:
    image: docker.io/bitnami/mongodb:5.0
    restart: unless-stopped
    volumes:
      - mongodb_data:/bitnami/mongodb
    environment:
      MONGODB_REPLICA_SET_MODE: "primary"
      MONGODB_REPLICA_SET_NAME: "rs0"
      MONGODB_PORT_NUMBER: 27017
      MONGODB_INITIAL_PRIMARY_HOST: "mongodb"
      MONGODB_INITIAL_PRIMARY_PORT_NUMBER: 27017
      MONGODB_ADVERTISED_HOSTNAME: "mongodb"
      MONGODB_ENABLE_JOURNAL: "true"
      ALLOW_EMPTY_PASSWORD: "yes"

volumes:
  mongodb_data:


docker-compose up -d
```

## Caddyfile

```caddyfile
chat.int.de {
  reverse_proxy localhost:18423
}
```