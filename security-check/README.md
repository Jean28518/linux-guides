# Security Checks for Linux Server

## Software
- Are Updates available?
- Are PPAs or other sources activated?
- Are automatic security updates activated?
- Is log4j detected?
- Is unused software installed?
- Is wine installed?


## Network Security
- Which ports are open?
- Is a firewall installed and active?
- Is root login over ssh deactivated?
- Is password login over ssh activated?
- Is the ssh port changed?
- Is 2FA over ssh activated?
- Is fail2ban activated?
- Is sshguard activated and installed?
- Is only https activated?

## Process Security
- Are processes running as root?
- Is a automatic backup system set up?
- Is the system at the newest version?
- Are the used passwords safe?
- Are having mysql users the right to drop tables? https://stackoverflow.com/questions/64013450/how-to-remove-user-privileges-associated-with-the-dropped-table
- Are suspicous processes running on your system?

## File security
- Any passwords in plain files found? What do they reveal?
- Are the owners/groups of the file correct?
- Can others see the files?


## Checks with:
- arachni-scanner
