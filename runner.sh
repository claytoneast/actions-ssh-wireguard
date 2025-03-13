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
sudo echo "$WIREGUARD_CONFIG" > /etc/wireguard/wg0.conf
sudo echo "$SSH_KEY" > /ssh.pub

echo "Successfully created Wireguard config files"
# Set permissions
sudo chmod 600 /ssh.pub

# Check the validity of the SSH key
ssh-keygen -l -f /ssh.pub

echo "Starting WireGuard..."
# Start wireguard
wg-quick up wg0

echo "Running SSH script..."
ssh -o ConnectTimeout=30 -o BatchMode=yes -o StrictHostKeyChecking=accept-new -i /ssh.pub -p "$SSH_PORT" "$SSH_USER"@"$SSH_HOST" "$SSH_SCRIPT"
