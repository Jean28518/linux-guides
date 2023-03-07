# FreeIPA with docker

```bash
# Create a new file:
vim /etc/docker/daemon.json

#Insert:
{ "userns-remap": "default" }

## ATTENTION!!! THIS BREAKS ALL OTHER RUNNING CONTAINERS BECAUSE OF OTHER PERMISSONS!!!
systemctl restart docker*


docker run -d --name freeipa-server-container -ti \
    --restart unless-stopped \
    -h ipa.int.de --read-only \
    -p 10080:80 -p 10443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 \
    -p 88:88/udp -p 464:464/udp -p 123:123/udp \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    -e PASSWORD=Fook5uef \
    -v /var/lib/ipa-data:/data:Z freeipa/freeipa-server:almalinux-9-4.10.0 \
    ipa-server-install -U -r INT.DE --no-ntp

# The first startup takes a lot of time and needs **really** at least 2GB of free RAM.
# Credentials on web ui are:
# admin
# Fook5uef
```

## Caddyfile entry:
```
ipa.int.de {
  reverse_proxy https://ipa.int.de:10443 {
    transport http {
      tls_insecure_skip_verify
    }
  }
}
```
