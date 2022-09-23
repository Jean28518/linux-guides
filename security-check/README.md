# Security Checks for Linux Server

## Software
- Are Updates available?
- Are PPAs or other sources activated?
- Are automatic security updates activated?
- Is log4j detected?


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

## File security
- Any passwords in plain files found? What do they reveal?
