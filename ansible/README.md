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

# To gather facts@ ANSIBLE_HOST_KEY_CHECKING=False ansible myhosts -m ping -i inventory.ini

vim playbook.yml
```

```yaml
---
- name: Setup Hosts
  hosts: myhosts
  become: true
  
  tasks:
    # - name: Configure GRUB PC
    #   ansible.builtin.debconf:
    #     name: grub-pc
    #     question: grub-pc/install_devices
    #     value: "/dev/sda"
    #     vtype: multiselect

    - name: Update System
      ansible.builtin.apt:
        update_cache: true
        upgrade: full

    - name: Define weekly reboot
      ansible.builtin.cron:
        name: "weekly reboot"
        weekday: "0"
        minute: "0"
        hour: "1"
        user: root
        job: "/usr/sbin/reboot"
        cron_file: ansible_weekly-reboot

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
```
```bash
ansible-playbook -i inventory.ini playbook.yml
```
## Ansible Roles

```bash

# To create a role:
mkdir roles
cd roles
ansible-galaxy init myrole
cd -

# In the playbook.yml:
```
```yml
---
- name: Setup Hosts
  hosts: myhosts
  become: true  

  vars:
    my_var: "Hello World"
    
  roles:
    - myrole

```
