# Connect Windows to Linux Workspace

## Prepare Virtual Machine

- Start Download for Windows 10
- Install the newest VirtualBox version from the official website
- Download the extension pack for VirtualBox.
- Install VirtualBox and the extension pack.
- Run `sudo usermod -a -G vboxusers username`
- Restart the computer
- Create a new Virtual Machine and assign 4 to 8 GB of RAM and at least 2 CPU-Cores.
- 3D acceleration is NOt recommended
- Install Windows 10, you can call the user "Linux"
- Install the VirtualBoxGuestAdditions in Windows.
- Create a shared folder and activate the bidirectional copy buffer.
- Create a desktop shortcut for the virtual machine and move it to .local/share/applications.
- Create Snapshot

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
