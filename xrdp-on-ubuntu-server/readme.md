# Xrdp for ubuntu server

```bash
sudo apt install xfce4 xrdp


sudo vim /etc/xrdp/startwm.sh

# Comment the following lines out and add startxfce4
#test -x /etc/X11/Xsession && exec /etc/X11/Xsession
#exec /bin/sh /etc/X11/Xsession
startxfce4



sudo systemctl restart xrdp
```