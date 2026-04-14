# Ansible

## Setup / Installation

On debian 13:

```bash
sudo apt install ansible

mkdir ansible && cd ansible
vim inventory.ini
```

Group hosts in your inventory logically according to their What, Where, and When.
```ini
[myhosts]
192.0.2.50 
192.0.2.51
192.0.2.52

[myhosts:vars]
ansible_user=root
# Optional:
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

```bash
# Validate
ansible-inventory -i inventory.ini --list

# Make sure an ssh key of the control node is in the authorized_keys of the manged nodes root user 

# If you connect the first time to the hosts:
ANSIBLE_HOST_KEY_CHECKING=False ansible myhosts -m ping -i inventory.ini

vim setup.yml
```

```yaml
- name: Setup Hosts
  hosts: myhosts
  
  tasks:
   - name: Update System
     ansible.builtin.apt:
       update_cache: true
       upgrade: full
   - name: Install basic tools
     ansible.builtin.apt:
       name:
         - vim
         - ufw
         - ncdu
         - htop
         - git
         - pwgen
         - curl
         - unzip
         - psmisc
         - fail2ban
         - cron
        state: present

   - name: Print message
     ansible.builtin.debug:
       msg: Hello world
```
```bash
ansible-playbook -i inventory.ini setup.yml
```
