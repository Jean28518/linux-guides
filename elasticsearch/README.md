# Elastic Search

```bash
sudo -i
cd && mkdir elasticsearch && cd elasticsearch && vim docker-compose.yml
# Insert:
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:latest
    ports:
      - "9200:9200"
      - "9300:9300"
    environment:
      - discovery.type=single-node


docker-compose up -d
```
