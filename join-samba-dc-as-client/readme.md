# Join a AD Domain (Samba DC)

## Samba-DC-Server

```bash
ufw allow 53 # DNS
ufw allow 88 # Kerberos
ufw allow 198 # Kerberos
ufw allow 464 # Kerberos
ufw allow 3629 # LDAPS-GC
# There are still some port openings missing
```

## Join Client

$IP is the IP-Adress of the Samba DC Server
$COMPUTER_NAME is the name of this client

```bash
# Samba server IP address
rm /etc/resolv.conf
echo "nameserver $IP" >> /etc/resolv.conf
echo "nameserver 208.67.222.222" >> /etc/resolv.conf

realm discover INT.DE

LDAPTLS_REQCERT=never LANG=C /usr/sbin/adcli join --verbose --domain int.de --domain-realm INT.DE --use-ldaps --domain-controller $IP --computer-name $COMPUTER_NAME --login-type user --login-user Administrator
```
