# ERP Next

```bash
git clone https://github.com/frappe/frappe_docker.git
cd frappe_docker
vim pwd.yml
# Change Port 8080 to 29323 in the frontend service
# The rest should be fine.
docker-compose -f pwd.yml up -d
```

## Caddyfile

```Caddyfile
erp.int.de {
  reverse_proxy localhost:29323
}
```

## Access

- Wait for about 5 to 10 Minutes.
- Access your instance via webbrowser.
- Your first login is:
  - Username: `Administrator`
  - Password: `admin`
