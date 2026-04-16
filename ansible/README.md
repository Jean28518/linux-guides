# Ansible Quickstart Guide

## Setup & Inventory

**Install:**
```bash
sudo apt update && sudo apt install ansible -y
```

**Configure Inventory (`inventory.ini`):**
```ini
[webservers]
192.168.1.10 ansible_user=ansible_admin

[webservers:vars]
ansible_become=true
```

**Test Connectivity:**
```bash
ansible all -i inventory.ini -m ping
```

---

## Playbooks (The Basics)
Create `basic-setup.yml`:
```yaml
---
- name: Infrastructure Baseline
  hosts: all
  become: true
  tasks:
    - name: Update all packages
      ansible.builtin.apt:
        upgrade: dist
        update_cache: true

    - name: Install essential tools
      ansible.builtin.apt:
        name: [vim, git, htop, ufw]
        state: present
```
**Run:** `ansible-playbook -i inventory.ini basic-setup.yml`

---

## Scaling with Roles
Roles modularize your automation. Generate the structure:
```bash
ansible-galaxy role init roles/webserver
```

### Key Directory Structure:
* `tasks/main.yml`: Primary execution logic.
* `handlers/main.yml`: Triggered events (e.g., service restarts).
* `templates/*.j2`: Dynamic files using Jinja2.
* `defaults/main.yml`: Default variable values.

### Example: Webserver Role
**`roles/webserver/tasks/main.yml`**:
```yaml
- name: Install Caddy
  ansible.builtin.apt:
    name: caddy
    state: present

- name: Deploy Index
  ansible.builtin.template:
    src: index.html.j2
    dest: /usr/share/caddy/index.html
  notify: Restart Caddy
```

**`roles/webserver/handlers/main.yml`**:
```yaml
- name: Restart Caddy
  ansible.builtin.systemd:
    name: caddy
    state: restarted
```

---

## 5. Execution
Combine everything in a master file `site.yml`:
```yaml
---
- hosts: webservers
  roles:
    - webserver
```
**Execute:**
```bash
ansible-playbook -i inventory.ini site.yml
```
