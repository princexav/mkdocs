#!/bin/bash
set -e

# Update system
apt-get update -y
apt-get upgrade -y

# Install k3s server (master)
curl -sfL https://get.k3s.io | K3S_TOKEN="${k3s_token}" sh -s - server \
  --write-kubeconfig-mode 644 \
  --tls-san $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) \
  --node-name k3s-master

# Wait for k3s to be ready
until kubectl get nodes; do
  sleep 2
done

echo "k3s master ready"
