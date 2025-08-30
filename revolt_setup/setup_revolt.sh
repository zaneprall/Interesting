#!/bin/bash
# Setup script for a self-hosted Revolt chat server on a fresh Debian VPS.
# This script assumes it is run as root. It checks and installs required
# packages, clones the Revolt self-hosted repository, and starts the services.

set -euo pipefail

CONFIG_FILE="${CONFIG_FILE:-$(dirname "$0")/.config}"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Configuration file $CONFIG_FILE not found. Aborting." >&2
  exit 1
fi

# shellcheck source=.config
. "$CONFIG_FILE"

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Helper to ensure a package is installed
ensure_pkg() {
  local pkg="$1"
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "Installing $pkg..."
    apt-get install -y "$pkg"
  fi
}

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. Cannot continue on this system." >&2
  exit 1
fi

apt-get update -y
apt-get upgrade -y

# Required packages for minimal Debian/IONOS VPS
for pkg in curl git ufw ca-certificates gnupg lsb-release apt-transport-https docker.io unattended-upgrades; do
  ensure_pkg "$pkg"
done

# Install Docker compose plugin if available, fall back to docker-compose
if ! docker compose version >/dev/null 2>&1; then
  ensure_pkg docker-compose-plugin || true
fi
if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
else
  ensure_pkg docker-compose
  COMPOSE_CMD="docker-compose"
fi

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Enable automatic security updates
systemctl enable --now unattended-upgrades

# Configure firewall
ufw allow ssh || true
ufw allow "$HTTP_PORT"/tcp || true
ufw allow "$HTTPS_PORT"/tcp || true
ufw --force enable || true

# Set timezone if requested
if [ -n "$TIMEZONE" ]; then
  timedatectl set-timezone "$TIMEZONE" || true
fi

# Create user and directories
if ! id "$REVOLT_USER" >/dev/null 2>&1; then
  useradd -m -d "$REVOLT_HOME" "$REVOLT_USER"
fi
usermod -aG docker "$REVOLT_USER"

mkdir -p "$REVOLT_HOME"
chown "$REVOLT_USER":"$REVOLT_USER" "$REVOLT_HOME"

# Clone or update repository
if [ ! -d "$REVOLT_HOME/self-hosted" ]; then
  git clone "$SELF_HOSTED_REPO" "$REVOLT_HOME/self-hosted"
else
  cd "$REVOLT_HOME/self-hosted"
  git pull
fi

cd "$REVOLT_HOME/self-hosted"

# Create .env file for docker compose
cat > .env <<ENV
DOMAINS__APP=$APP_DOMAIN
DOMAINS__API=$API_DOMAIN
DOMAINS__CDN=$CDN_DOMAIN
TRUSTED_PROXIES=127.0.0.1/32
ADMIN_EMAIL=$ADMIN_EMAIL
ENV

# Start services
if [ -f docker-compose.yml ]; then
  $COMPOSE_CMD pull
  $COMPOSE_CMD up -d
else
  echo "docker-compose.yml not found. Installation may have failed." >&2
  exit 1
fi

cat <<MSG
Revolt server setup complete.
Ensure DNS for $APP_DOMAIN, $API_DOMAIN and $CDN_DOMAIN points to this server.
MSG

