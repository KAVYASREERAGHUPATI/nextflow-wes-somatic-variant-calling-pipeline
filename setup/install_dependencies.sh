#!/bin/bash


# Install Nextflow and Docker

# This script installs the main dependencies required to run the Nextflow WES somatic variant calling pipeline on Ubuntu.


set -e

# Step 1: Update system packages

echo "Updating system packages..."

sudo apt-get update



# Step 2: Install Java

echo "Installing Java..."

sudo apt-get install -y openjdk-17-jre-headless curl

echo "Java installation completed."

java -version



# Step 3: Install Nextflow


echo "Installing Nextflow..."

curl -s https://get.nextflow.io | bash

sudo mv nextflow /usr/local/bin/nextflow

echo "Nextflow installation completed."

nextflow -version



# Step 4: Install Docker

echo "Installing Docker..."

sudo apt-get install -y docker.io

sudo systemctl enable docker
sudo systemctl start docker

echo "Docker installation completed."

docker --version



# Step 5: Configure Docker for the current user


echo "Adding current user to the Docker group..."

sudo usermod -aG docker "$USER"

echo "Docker user configuration completed."



# Installation Complete

echo "Then verify Docker using:"
echo "docker run hello-world"
