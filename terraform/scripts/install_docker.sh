#!/bin/bash
sudo apt-get update -y

# Install Docker Engine and the Compose V2 Plugin together
sudo apt-get install docker.io docker-compose-v2 -y

# Start and enable Docker services
sudo systemctl start docker
sudo systemctl enable docker

# Add the default ubuntu user to the docker group so you don't need 'sudo'
sudo usermod -aG docker ubuntu && newgrp docker
