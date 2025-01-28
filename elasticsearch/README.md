# Elastic Search

<https://www.elastic.co/guide/en/elasticsearch/reference/7.5/docker.html>

Tags: <https://hub.docker.com/_/elasticsearch/tags>

```bash
sudo -i
cd && mkdir elasticsearch && cd elasticsearch && vim docker-compose.yml
# Insert:
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.17.1
    ports:
      - "9200:9200"
      - "9300:9300"
    environment:
      - discovery.type=single-node


docker-compose up -d
```
