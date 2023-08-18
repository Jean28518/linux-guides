# Open LDAP on ubuntu

License of this file: <https://github.com/menzelit/bm-uni.de/blob/main/LICENSE>
Inspired by: <https://github.com/menzelit/bm-uni.de/>

```bash
sudo -i
apt update && apt dist-upgrade -y
hostnamectl set-hostname ldap.int.de
sed -i "s/^127.0.1.1.*/127.0.1.1 ldap.int.de ldap.int.de/g" /etc/hosts
bash

basedn="dc=int,dc=de"
admindn="cn=admin,$basedn"
adminpwd="eeG4meth"
echo -e "\$basedn:\t$basedn\n\$admindn:\t$admindn\n\$adminpwd:\t$adminpwd"

apt install slapd

systemctl stop slapd
sed -i "s/SLAPD_CONF=.*/SLAPD_CONF=\/etc\/ldap\/slapd.conf/g" /etc/default/slapd
cat /etc/default/slapd
rm /var/lib/ldap/*.mdb

adminpwdHash=$(slappasswd -h {SSHA} -s $adminpwd)
cat <<EOF >/etc/ldap/slapd.conf
```

```bash
# Schemata und Objektklassen
include         /etc/ldap/schema/core.schema
include         /etc/ldap/schema/cosine.schema
include         /etc/ldap/schema/inetorgperson.schema
include         /etc/ldap/schema/nis.schema
# Loglevel - 256 ist ein guter Mittelwert
# NICHT auf 0 setzen, da sonst gar nichts geloggt wird!
# https://www.openldap.org/doc/admin24/slapdconfig.html
loglevel        256
pidfile         /var/run/slapd/slapd.pid
argsfile        /var/run/slapd/slapd.args
modulepath      /usr/lib/ldap
moduleload      back_mdb
# Maximal 1000 Werte bei einer Suche zurück geben
sizelimit 1000
# Anzahl CPUs, die für das Indexing verwendet werden
tool-threads 2
#######################################################################
# Datenbank Nummer 1
database        mdb
# Der Basis-DN
suffix          "$basedn"
# Root-User
rootdn          "$admindn"
rootpw          "$adminpwdHash"
# Ablageort der Datenbank
directory       "/var/lib/ldap"
# Indices
index           objectClass eq
# Letzte Modifikation der Datenbank schreiben
lastmod         on
# Access Control Lists
include         /etc/ldap/acl.conf
```

## ACL
```bash
cat <<EOF >/etc/ldap/acl.conf
access to dn.base="$basedn" by * read

access to attrs=userPassword,shadowLastChange
        by anonymous auth
        by self write
        by group.exact="cn=administration,ou=groups,$basedn" write
        by * none

access to dn.subtree="ou=binduser,$basedn"
        by group.exact="cn=administration,ou=groups,$basedn" write
        by * none

access to dn.subtree="ou=groups,$basedn"
        by group.exact="cn=administration,ou=groups,$basedn" write
        by dn.one="ou=binduser,$basedn" read
        by * none

access to dn.subtree="ou=users,$basedn"
        by group.exact="cn=administration,ou=groups,$basedn" write
        by dn.one="ou=binduser,$basedn" read
        by self read
        by * none

access to * by * none
EOF
```

## RFC2307bis
```bash
wget -P /etc/ldap/schema https://raw.githubusercontent.com/jtyr/rfc2307bis/master/rfc2307bis.schema
sed -i "s/nis.schema/rfc2307bis.schema/" /etc/ldap/slapd.conf
systemctl restart slapd
systemctl status slapd
```

## First data (Very basic but essential)
```bash
cat <<EOF >/tmp/basic.ldif
# Base erstellen
dn: $basedn
objectClass: dcObject
objectClass: organization
o: Organisation
dc: int

# Gruppen erstellen
dn: ou=groups,$basedn
ou: groups
objectClass: top
objectClass: organizationalUnit

# User erstellen
dn: ou=users,$basedn
ou: users
objectClass: top
objectClass: organizationalUnit

# posixGruppe anlegen
dn: cn=posixGruppe,ou=groups,$basedn
cn: posixGruppe
objectClass: top
objectClass: posixGroup
gidNumber: 10000

# binduser
dn: ou=binduser,$basedn
ou: binduser
objectClass: top
objectClass: organizationalUnit
EOF

ldapadd -x -H "ldap://ldap.int.de" -D "$admindn" -w $adminpwd -f /tmp/basic.ldif
```

## Test LDAP:

```bash
ldapsearch -x -LLL -H "ldap://ldap.int.de" -b $basedn -D "$admindn" -w $adminpwd
```

## LDAPS (doesn't work at the moment)
- We are using the root and key certificate of caddy at `/var/lib/caddy/.local/share/caddy/pki/authorities/`
- Let's create a script which retrieves the certificates and perpares them for openldap. 

```bash
vim /root/retrieve_certificates.sh && chmod +x /root/retrieve_certificates.sh

# Insert (adjust the paths suitable for the correct authority):
KEYFILE=/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.key
CRTFILE=/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt

cp $KEYFILE /etc/ldap/ldapkey.pem
cp $CRTFILE /etc/ldap/ldapcert.pem

chmod 600 /etc/ldap/ldapkey.pem
chmod 600 /etc/ldap/ldapcert.pem

chown openldap /etc/ldap/ldapkey.pem
chown openldap /etc/ldap/ldapcert.pem
```


```bash
sed -i '/^tool-threads*/a TLSCertificateKeyFile \/etc\/ldap\/ldapkey.pem' /etc/ldap/slapd.conf
sed -i '/^tool-threads*/a TLSCertificateFile \/etc\/ldap\/ldapcert.pem' /etc/ldap/slapd.conf
sed -i '/^tool-threads*/a # SSL Certs' /etc/ldap/slapd.conf
sed -i 's/SLAPD_SERVICES=.*/SLAPD_SERVICES="ldapi:\/\/\/ ldaps:\/\/\/"/g' /etc/default/slapd
systemctl restart slapd

# Test ldaps:
ldapsearch -x -LLL -H "ldaps://ldap.int.de" -b $basedn -D "$admindn" -w $adminpwd
```

## Clear whole LDAP-Server:

```bash
systemctl stop slapd
rm /var/lib/ldap/*.mdb
systemctl start slapd
```

You may now want to add the basic.ldif data again.
