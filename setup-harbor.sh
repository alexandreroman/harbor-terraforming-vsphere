#!/bin/sh

. /home/ubuntu/.env

# Set up HTTP proxy support
if ! [ -z "$HTTP_PROXY_HOST" ]; then
  export http_proxy=http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}
  export https_proxy=http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}
  export NO_PROXY=localhost,127.0.0.1,.local

  cat <<EOF >> /home/ubuntu/apt-proxy
Acquire {
  HTTP::proxy "http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}";
  HTTPS::proxy "http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}";
}
EOF
  sudo mv /home/ubuntu/apt-proxy /etc/apt/apt.conf.d/proxy
  sudo snap set system proxy.http="http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}"
  sudo snap set system proxy.https="http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}"

  cat <<EOF >> /home/ubuntu/docker-proxy
[Service]
Environment="HTTP_PROXY=http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}"
Environment="HTTPS_PROXY=http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}"
Environment="NO_PROXY="localhost,127.0.0.1,::1,.local"
EOF
  sudo mkdir -p /etc/systemd/system/docker.service.d
  sudo mv /home/ubuntu/docker-proxy /etc/systemd/system/docker.service.d/proxy.conf
fi

# Configure VIm.
if ! [ -f /home/ubuntu/.vimrc ]; then
  cat <<EOF >> /home/ubuntu/.vimrc
set ts=2
set sw=2
set ai
set et
EOF
fi

# Install Docker.
sudo apt-get update && \
sudo apt-get -y install docker.io && \
sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker && \
sudo usermod -aG docker ubuntu

# Install Docker Compose.
curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /home/ubuntu/docker-compose && \
chmod +x /home/ubuntu/docker-compose && \
sudo mv /home/ubuntu/docker-compose /usr/local/bin

# Download and extract Harbor installer.
export HARBOR_VERSION=2.3.0
curl -L https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/harbor-online-installer-v${HARBOR_VERSION}.tgz -o /home/ubuntu/harbor-online-installer.tgz && \
cd /home/ubuntu && tar zxvf harbor-online-installer.tgz

# Generate Harbor configuration.
cat <<EOF > /home/ubuntu/harbor/harbor.yml
hostname: ${HARBOR_HOSTNAME}
https:
  certificate: /home/ubuntu/tls-harbor.crt
  private_key: /home/ubuntu/tls-harbor.key

external_url: https://${HARBOR_HOSTNAME}
harbor_admin_password: ${HARBOR_ADMIN_PASSWORD}

database:
  password: root123

data_volume: /home/ubuntu/harbor/data

jobservice:
  max_job_workers: 10

notification:
  webhook_job_max_retry: 10

log:
  level: info
  local:
    location: /var/log/harbor

chart:
  absolute_url: https://charts.${HARBOR_HOSTNAME}
EOF

if ! [ -z "$HTTP_PROXY_HOST" ]; then
  cat <<EOF >> /home/ubuntu/harbor/harbor.yml

proxy:
  http_proxy: http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}
  https_proxy: http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}
  components:
    - core
    - jobservice
    - trivy
EOF
fi

# Start Harbor installer.
sudo /home/ubuntu/harbor/install.sh --with-trivy --with-chartmuseum
