#!/bin/bash
set -e

# Update system
apt-get update -y
apt-get upgrade -y

# Install Nginx
apt-get install -y nginx

# Create deployment directory
mkdir -p /var/www/healthpulse
mkdir -p /var/www/healthpulse-backups
chown -R ubuntu:ubuntu /var/www/healthpulse
chown -R ubuntu:ubuntu /var/www/healthpulse-backups

# Configure Nginx for HealthPulse (write config without nested heredoc)
cat > /etc/nginx/sites-available/healthpulse <<'NGINXCONF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/healthpulse;
    index index.html;

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;
    gzip_min_length 1000;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location /health {
        access_log off;
        return 200 '{"status":"healthy","deploy":"baremetal"}';
        add_header Content-Type application/json;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
NGINXCONF

# Enable site and disable default
ln -sf /etc/nginx/sites-available/healthpulse /etc/nginx/sites-enabled/healthpulse
rm -f /etc/nginx/sites-enabled/default

# Test and start Nginx
nginx -t
systemctl enable nginx
systemctl restart nginx

echo "HealthPulse bare-metal server ready" > /var/www/healthpulse/index.html
chown -R ubuntu:ubuntu /var/www/healthpulse
