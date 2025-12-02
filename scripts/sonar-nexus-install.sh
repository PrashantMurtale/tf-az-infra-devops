#!/bin/bash
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl enable docker
sudo usermod -aG docker azureuser

# SonarQube & Nexus via Docker
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
sudo docker run -d --name nexus -p 8081:8081 sonatype/nexus3
