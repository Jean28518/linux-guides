# FreeIPA with podman

<https://hub.docker.com/r/freeipa/freeipa-server/tags>

```bash
mkdir /var/lib/ipa-data/ && cd && mkdir freeipa && cd freeipa && vim run.sh

# Insert the following text.
podman run -d --name freeipa-server-container -ti \
    --restart unless-stopped \
    -h ipa.int.de --read-only \
    -p 10080:80 -p 10443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 \
    -p 88:88/udp -p 464:464/udp -p 123:123/udp \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    -e PASSWORD=Fook5uef \
    -v /var/lib/ipa-data:/data:Z docker.io/freeipa/freeipa-server:almalinux-9-4.10.1 \
    ipa-server-install -U -r INT.DE --no-ntp

# Inspect the latest tag here: https://hub.docker.com/r/freeipa/freeipa-server/tags
# Change the hostname ipa.int.de to your needs

sudo bash run.sh

# The first startup takes a lot of time and needs **really** at least 2GB of free RAM.
# Credentials on web ui are:
# admin
# Fook5uef
# Warning: The web interface could be up and running but the login may fails for the first minutes. 
# Wait for about 10 minutes at a minimum.

# Configure automatic start after reboot.
sudo podman generate systemd --new --name freeipa-server-container > /etc/systemd/system/freeipa.service
sudo systemctl enable freeipa.service
# Test it out by rebooting the whole server.
```

## Caddyfile entry

```caddyfile
ipa.int.de {
  reverse_proxy https://localhost:10443 {
    transport http {
      tls_insecure_skip_verify
    }
  }
}
```

## Firewall

```bash
ufw allow 389   # For LDAP
ufw allow 636   # For LDAPS
ufw allow 88    # For Keberos
ufw allow 464   # For Kerberos
```

## Further documentation

<https://github.com/Jean28518/linux-guides/tree/main/freeipa-alma-linux-9>

## How to update

```bash
vim run.sh
# Update the tag, comment out the last line 'ipa-server-install'
systemctl disable freeipa --now

podman ps -a
podman rm ID # If the container is available

# Now run the run.sh and regenerate and reactivate the systemctl as described in the setup.
# Hint: The startup of freeipa takes five minute until it is reachable and fully working again.
```
