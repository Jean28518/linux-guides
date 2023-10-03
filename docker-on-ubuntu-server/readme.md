# Install docker

## Ubuntu 

<https://docs.docker.com/engine/install/ubuntu/>

```bash
sudo snap remove docker && sudo apt remove docker* containerd runc && sudo apt install ca-certificates curl gnupg lsb-release && sudo mkdir -m 0755 -p /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

# Verify that everything is okay:
# If something fails, try to reboot
sudo docker run hello-world

```

## Debian
```bash
sudo apt install docker.io docker-compose
```
