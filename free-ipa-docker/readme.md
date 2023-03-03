# FreeIPA with docker

```
# Create a new file:
vim /etc/docker/daemon.json

#Insert:
{ "userns-remap": "default" }


systemctl restart docker*


docker run -d --name freeipa-server-container -ti \
    -h ipa.li-ar.de --read-only \
    -p 10080:80 -p 10443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 \
    -p 88:88/udp -p 464:464/udp -p 123:123/udp \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    -e PASSWORD=Secret123 \
    -v /var/lib/ipa-data:/data:Z freeipa/freeipa-server:almalinux-9-4.10.0 \
    ipa-server-install -U -r LI-AR.TEST --no-ntp

# The first startup takes a lot of time and needs at least 2GB of free RAM.
```