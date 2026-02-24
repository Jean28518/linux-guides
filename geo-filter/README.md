# nft-geo-filter

Thanks to: https://github.com/rpthms/nft-geo-filter/tree/master

```bash
wget https://raw.githubusercontent.com/rpthms/nft-geo-filter/master/nft-geo-filter -O /usr/bin/nft-geo-filter
chmod +x /usr/bin/nft-geo-filter

mkdir -p /root/.scripts/
# Change the interface and the country codes you want to allow
echo '#!/bin/bash
nft-geo-filter \
	--table-family inet\
	--provider ipdeny.com\
	--interface enp0s3\
	--allow-established\
	--allow DE AT CH IE' > /root/.scripts/geofilter.sh
chmod +x /root/.scripts/geofilter.sh

echo "[Unit]
Description=nftables Country Filter Timer

[Timer]
OnBootSec=1min
OnUnitActiveSec=12h

[Install]
WantedBy=timers.target" > /etc/systemd/system/nft-geo-filter.timer



echo "[Unit]
Description=nftables Country Filter

[Service]
Type=oneshot
ExecStart=/root/.scripts/geofilter.sh" > /etc/systemd/system/nft-geo-filter.service

systemctl enable nft-geo-filter
```
