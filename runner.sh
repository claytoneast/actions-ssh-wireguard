#!/bin/bash
set -e
echo "=== WireGuard/SSH GitHub Action ==="

SSH_USER=${SSH_USER:-root}
SSH_PORT=${SSH_PORT:-22}
SSH_HOST=${SSH_HOST}
SSH_KEY=${SSH_KEY}
SSH_SCRIPT=${SSH_SCRIPT}
WIREGUARD_CONFIG=${WIREGUARD_CONFIG}

[ -z "$SSH_HOST" ] && echo "Missing SSH_HOST argument"
[ -z "$SSH_KEY" ] && echo "Missing SSH_KEY argument"
[ -z "$SSH_SCRIPT" ] && echo "Missing SSH_SCRIPT argument"
[ -z "$WIREGUARD_CONFIG" ] && echo "Missing WIREGUARD_CONFIG argument"

echo "Installing WireGuard and SSH..."
# Install wireguard
sudo apt-get update -y
sudo apt-get install -y wireguard openssh-client resolvconf

echo "Configuring WireGuard..."
# Create wireguard config
echo "$WIREGUARD_CONFIG" | sudo tee /etc/wireguard/wg0.conf > /dev/null
echo "$SSH_KEY" | sudo tee /ssh.private > /dev/null

echo "Successfully created Wireguard config files"

# Check the validity of the SSH key
ssh-keygen -l -f /ssh.private

# start ssh-agent
eval "$(ssh-agent -s)"
# Add the SSH key to the agent
ssh-add /ssh.private

echo "Starting WireGuard..."
# Start wireguard
wg-quick up wg0

echo "Running SSH script..."
ssh -o ConnectTimeout=30 -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ForwardAgent=yes -i /ssh.private -p "$SSH_PORT" "$SSH_USER"@"$SSH_HOST" "$SSH_SCRIPT"
