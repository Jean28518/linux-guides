# Setup local DNS Server on Ubuntu

```bash


sudo apt install dnsmasq vim
sudo rm /etc/resolv.conf # Remove symlink
sudo vim /etc/resolv.conf
```
Insert the following content:
```bash
nameserver 127.0.0.1
nameserver 192.168.178.84 # The ip of the server itself, needed for dns for docker containers
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
192.168.178.84 cert.int.de # Add this for the distribution of the cert file, which we will create in some steps
192.168.178.84 cloud.int.de
192.168.178.84 chat.int.de
```
Please avoid .local adresses because they are used in another ways. A not existent domain but with an existant top level domain is recommended that the browsers don't open the search automatically.

Finally switch the services
```bash
# Disable resolv.conf
sudo systemctl stop systemd-resolved.service
sudo systemctl disable systemd-resolved.service

sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq
sudo ufw allow 53
```


# Setup caddy to serve local, valid https:
```bash
sudo apt install libnss3-tools
sudo caddy trust

# Distribute the ca certificate on an own webserver:
sudo mkdir -p /var/www/cert/
sudo cp /etc/ssl/certs/Caddy_Local_Authority_[...].pem /var/www/cert/lan.crt

vim /etc/caddy/Caddyfile
```
1. add the following configuration for the distribution webserver:

```
cert.int.de {
  tls internal
  root * /var/www/cert/
  file_server browse
}
```

2. On every other host add the apropriate dns entry
3. Add for every host the following line:

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

# Setup the devices to use the domains and the good https (also needed for docker containers):
- Set the dns server of the system to the ip of the new dns server.
  - In docker containers the nameserver should be already configured. Check /etc/resolv.conf for that.
- Reconnect to the network
- Download the certificate of the server. (If you did everything right a valid address would be '192.168.178.84/lan.crt')
- Add this certificate to your browsers (because they have their own certificate handling)
    - Settings -> Privady & Security -> Show certificates (-> Certificate Authorities) -> Add certificate
- Add the certificate to your system by issuing the following commands
    - `sudo cp ~/Downloads/lan.crt /usr/local/share/ca-certificates/lan.crt`
    - `sudo update-ca-certificates`
- repeat this on every device which should use it


## Set Fritz!Box DNS-Settings:
- Internet -> Access Data -> DNS-Server
- **Also disable for DNS-Rebind-Protection in: Local Network -> Network -> Network Settings:**
    - insert `int.de` into the DNS-Rebind-Protection field
