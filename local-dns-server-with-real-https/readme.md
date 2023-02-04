# Setup local DNS Server on Ubuntu

```bash
# Disable resolv.conf
sudo systemctl stop systemd-resolved.service
sudo systemctl disable systemd-resolved.service

sudo apt install dnsmasq vim
sudo rm /etc/resolv.conf # Remove symlink
sudo vim /etc/resolv.conf
```
Insert the following content:
```bash
nameserver 127.0.0.1
nameserver 192.168.178.1
nameserver 8.8.8.8
```

```bash
sudo vim /etc/dnsmasq.conf
```
Append the following content to the very end:
```bash
listen-address=127.0.0.1
listen-address=192.168.178.84 # Ip of the server itself
```

## Add DNS entries:
These are stored in the /etc/hosts file.
Here are some example entries:
```
192.168.178.84 cloud.int.de
192.168.178.84 chat.int.de
```
Please avoid .local adresses because they are used in another ways. A not existent domain but with an existant top level domain is recommended that the browsers don't open the search automatically.

Finally restart the service
```bash
sudo systemctl restart dnsmasq
sudo ufw allow 53
```


# Setup caddy to serve local, valid https:
```bash
sudo apt install libnss3-tools
sudo caddy trust
# Copy the ca certificate to the webroot that other local machines can easily obtain it:
sudo cp /etc/ssl/certs/Caddy_Local_Authority_[...].pem /var/www/nextcloud/lan.crt

vim /etc/caddy/Caddyfile
```
- On every host add the apropriate dns entry
- Add for every host the following line:
```
tls internal
```
A full example would be:
```
cloud.int.de 192.168.178.84 {
  tls internal
  reverse_proxy localhost:3000
}
```

# Setup the devices to use the domains and the good https:
- Set the dns server of the system to the ip of the new dns server.
- Reconnect to the network
- Download the certificate of the server. (If you did everything right a valid address would be '192.168.178.84/lan.crt')
- Add this certificate to your browsers (because they have their own certificate handling)
    - Settings -> Privady & Security -> Show certificates (-> Certificate Authorities) -> Add certificate
- Add the certificate to your system by issuing the following commands
    - `sudo cp ~/Downloads/lan.crt /usr/local/share/ca-certificates/lan.crt`
    - `sudo update-ca-certificates`
- repeat this on every device which should use it

