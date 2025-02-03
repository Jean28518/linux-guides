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
    restart: unless-stopped
    labels:
       - elasticsearch
    ports:
      - "9200:9200"
      - "9300:9300"
    environment:
      - discovery.type=single-node


docker-compose up -d

docker cp elasticsearch-elasticsearch-1:/usr/share/elasticsearch/config/certs/http_ca.crt .
cp http_ca.crt /usr/local/share/ca-certificates/
update-ca-certificates
```
