# Hermes AI with Ollama

Today I'm gonna show you how to install Hermes AI Agent on Ubuntu Server. We will install Docker, Caddy as Reverse Proxy and afterwards Hermes with Ollama and an local AI Model for very simple tasks.

```bash
sudo apt update && sudo apt full-upgrade -y && sudo apt install vim ufw ncdu htop git pwgen curl unzip psmisc fail2ban cron tree -y
sudo apt install caddy

sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world

cd
mkdir hermes
cd hermes/
nano docker-compose.yml


services:
  hermes:
    image: nousresearch/hermes-agent:latest
    container_name: hermes
    restart: unless-stopped
    command: gateway run
    ports:
      - "9119:9119"
    volumes:
      - ./data:/opt/data
    environment:
      # Dashboard configuration
      - HERMES_DASHBOARD=1
      - HERMES_DASHBOARD_HOST=0.0.0.0
      - HERMES_DASHBOARD_PORT=9119
      - HERMES_DASHBOARD_BASIC_AUTH_USERNAME=
      - HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=
      - HERMES_DASHBOARD_INSECURE=1
	  - OPENAI_BASE_URL=http://ollama:11434/v1
      - OPENAI_API_KEY=ollama
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: unless-stopped
    volumes:
      - ollama:/root/.ollama

  ollama-pull:
    image: ollama/ollama:latest
    container_name: ollama-pull
    restart: "no"
    environment:
      - OLLAMA_HOST=ollama:11434
    depends_on:
      - ollama
    entrypoint: /bin/sh
    command: -c "echo 'Waiting for Ollama...' && sleep 10 && ollama pull deepseek-r1:1.5b && echo 'Hermes-Model loaded!'"

volumes:
  ollama:


docker compose up -d
```
