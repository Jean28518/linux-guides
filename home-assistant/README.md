# Home Assistant Install


## Create project directory

```bash
mkdir -p ~/home-assistant && cd ~/home-assistant
```

## Compose file

`vim ~/home-assistant/docker-compose.yml`

```yaml
services:
  homeassistant:
    container_name: homeassistant
    image: "ghcr.io/home-assistant/home-assistant:stable"
    volumes:
      - ./config:/config                    # persistent HA config
      - /etc/localtime:/etc/localtime:ro    # host timezone
      - /run/dbus:/run/dbus:ro              # Bluetooth via D-Bus
    restart: unless-stopped
    stop_grace_period: 60s
    privileged: true                        # device access (USB, BT); drop if not needed
    network_mode: host                      # device discovery, UI on port 8123
    environment:
      TZ: Europe/Berlin                     # adjust to your timezone
```

## Start

```bash
docker compose up -d      # pull image and start in background
docker ps                 # verify container "homeassistant" is running
docker logs -f homeassistant   # follow startup logs (Ctrl+C to exit)
```

## Access

```bash
ip a                      # find host IP, e.g. 192.168.178.27
```

Open `http://<HOST_IP>:8123` in a browser and complete the onboarding wizard (create the admin user, set location and units).
