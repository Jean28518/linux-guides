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

## Add Nextcloud WebDAV

- Open Windows Explorer, select "This PC".
- Select the "Computer" tab at the top
- Select the "Connect Networkdrive"
- Select the blue underlined "Connect to website on which documents and pictures can be stored"
- Insert the webdav adress
- Follow the instructions
