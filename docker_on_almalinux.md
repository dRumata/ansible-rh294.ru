 Here's how to install Docker on AlmaLinux:

## 1. Update system packages
bash
sudo dnf update -y


## 2. Install required packages
bash
sudo dnf install -y dnf-utils device-mapper-persistent-data lvm2


## 3. Add Docker repository
bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo


## 4. Install Docker
bash
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


## 5. Start and enable Docker service
bash
sudo systemctl start docker
sudo systemctl enable docker


## 6. Add user to docker group (optional)
bash
sudo usermod -aG docker $USER


## 7. Verify installation
bash
sudo docker run hello-world


After adding your user to the docker group, log out and back in (or run newgrp docker) to use Docker without sudo.
