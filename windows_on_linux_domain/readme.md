# Connect Windows to Linux Workspace

## Update DNS-Server

- In the start menu search for "Network Connections"
- Rightclick the Current Connection and select "Properties"
- Select IPv4 and select Properties

## Install Root Certificate

- Download lan.crt
- In the windows explorer left and rightclick this file and select "install certifacte"
- Select "local computer"
- Select "All certificates in the following space"
- Select "Trusted Root Certificate Issuers" ("Vertauenswürdige Stammzertifizierungstellen")
- Click on okay, next and finish.
- Restart Computer

## Add Nextcloud Drive

- WebDAV doesn't work properly. Use the official nextcloud client with virtual sync instead.
- Disable the server notifications in the nextcloud app settings.
