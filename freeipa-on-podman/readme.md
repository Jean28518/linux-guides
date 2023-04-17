# FreeIPA with podman

```bash
mkdir /var/lib/ipa-data/ && mkdir freeipa && cd freeipa && vim run.sh

# Insert the following text.
podman run -d --name freeipa-server-container -ti \
    --restart unless-stopped \
    -h ipa.int.de --read-only \
    -p 10080:80 -p 10443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 \
    -p 88:88/udp -p 464:464/udp -p 123:123/udp \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    -e PASSWORD=Fook5uef \
    -v /var/lib/ipa-data:/data:Z docker.io/freeipa/freeipa-server:almalinux-9-4.10.0 \
    ipa-server-install -U -r INT.DE --no-ntp

# Inspect the latest tag here: https://hub.docker.com/r/freeipa/freeipa-server/tags
# Change the hostname ipa.int.de to your needs

bash run.sh

# The first startup takes a lot of time and needs **really** at least 2GB of free RAM.
# Credentials on web ui are:
# admin
# Fook5uef
# Warning: The web interface could be up and running but the login may fails for the first minutes. 
# Wait for about 10 minutes at a minimum.
```

## Caddyfile entry

```caddyfile
ipa.int.de {
  reverse_proxy https://ipa.int.de:10443 {
    transport http {
      tls_insecure_skip_verify
    }
  }
}
```

## Further documentation

<https://github.com/Jean28518/linux-guides/tree/main/freeipa-alma-linux-9>