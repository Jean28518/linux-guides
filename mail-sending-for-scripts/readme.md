# Send mails from scripts in linux

```bash
sudo -i
apt install ssmtp mailutils -y
vim /etc/ssmtp/ssmtp.conf

# Config file for sSMTP sendmail
root=USER@gmail.com
mailhub=smtp.gmail.com:587
rewriteDomain=gmail.com
hostname=USER@gmail.com
FromLineOverride=YES
AuthUser=MYUSER
AuthPass=MYPASSWORD
UseSTARTTLS=YES
UseTLS=NO


# You can now send mails with (press Enter and Ctr+D in the end):
mail -a 'From: Linux-Arbeitsplatz <USER@gmail.com>' -s "Subject" recepient@address.com
# For scripts:
echo -e "\n\nThis is the body" | mail -a 'From: Linux-Arbeitsplatz <USER@gmail.com>' -s "Subject" recepient@address.com

# Attachment:
# -A /path/to/file
```
