# Gitlab CE

Based on <https://github.com/sameersbn/docker-gitlab/>

## Change SSH port of server itself

Because Gitlab will use the default SSH port 22, we need to change the port of the server itself.

```bash
vim /etc/ssh/sshd_config
```

```ssh
Port 23
```

```bash
ufw allow 23
systemctl restart ssh
# (Login with new port)
```

## Install Gitlab CE

```bash
mkdir -p /data/gitlab

cd && mkdir gitlab && cd gitlab
wget https://raw.githubusercontent.com/sameersbn/docker-gitlab/master/docker-compose.yml
# For Keys and Passwords
pwgen -Bsv1 64 4

vim docker-compose.yml
# Change the following lines:
  ports:
  - '22824:80'
  - '22:22'
  volumes:
    -TZ=Europe/Berlin
    -GITLAB_TIMEZONE=Berlin

    - GITLAB_HOST=gitlab.int.de
    - GITLAB_PORT=22824
    - GITLAB_SSH_PORT=22

    - GITLAB_SECRETS_DB_KEY_BASE=...
    - GITLAB_SECRETS_SECRET_KEY_BASE=...
    - GITLAB_SECRETS_OTP_KEY_BASE=...

    - GITLAB_ROOT_PASSWORD=...
    - GITLAB_ROOT_EMAIL=...

    # Change not GITLAB_HTTPS=false
```

```bash
docker-compose up -d
```

## Configure Caddy

```bash
vim /etc/caddy/Caddyfile
```

```caddy
gitlab.int.de {
    reverse_proxy localhost:22824
}
```

```bash
systemctl restart caddy
```

## Wait for Gitlab to start

```bash
# Wait a long time (5 Minutes):
docker-compose logs -f
```

## Configure Gitlab

- Login with your mail and password
- (Disable Sign-Up (Admin Area))
