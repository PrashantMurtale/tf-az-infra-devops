#!/bin/bash
set -e  # Exit on error
set -x  # Print commands for debugging

# Redirect output to log file
exec > >(tee /var/log/jenkins-install.log)
exec 2>&1

echo "Starting Jenkins installation at $(date)"

# Update package list
sudo apt update -y

# Install Java 11 and Docker
sudo apt install -y openjdk-11-jdk docker.io

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker azureuser

# Add Jenkins repository and key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list again
sudo apt update -y

# Install Jenkins
sudo apt install -y jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
sleep 30

# Check Jenkins status
sudo systemctl status jenkins --no-pager

echo "Jenkins installation completed at $(date)"
echo "Initial admin password location: /var/lib/jenkins/secrets/initialAdminPassword"
