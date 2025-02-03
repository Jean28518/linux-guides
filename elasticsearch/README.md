# Elastic Search

Very simple setup without proper authentication. For nextcloud single node instances this should be enough though if the network access is restricted.

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
      - xpack.security.enabled=false  # Disable security



docker-compose up -d

# Only needed if xpack security is enabled.
# docker cp elasticsearch-elasticsearch-1:/usr/share/elasticsearch/config/certs/http_ca.crt .
# cp http_ca.crt /usr/local/share/ca-certificates/
# update-ca-certificates
```

## How to use it with nextcloud:


16GB of RAM or more are recommended if you want to index more than 50GB of data.


- In nextcloud install: `fulltextsearch` and `fulltextsearch_elasticsearch`
- In the admin settings under full text search configure the server with address `http://localhost:9200` (if you disabled xpack.security) and with index e.g. `my_index`.
- Then run `sudo -u www-data php /var/www/nextcloud/occ fulltextsearch:index` to start the index. This will take many minutes :)

### Enable continously file indexing:

Initially posted at: https://www.allerstorfer.at/install-nextcloud-elasticsearch/

```bash
vim /etc/systemd/system/nextcloud-fulltext-elasticsearch-worker.service
# Insert:
[Unit]
Description=Elasticsearch Worker for Nextcloud Fulltext Search
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/nextcloud
ExecStart=/usr/bin/php /var/www/nextcloud/occ fulltextsearch:live
Nice=19
Restart=always

[Install]
WantedBy=multi-user.target


systemctl enable nextcloud-fulltext-elasticsearch-worker.service --now
```


