#!/usr/bin/env bash
# Prepares a fresh Ubuntu 24.04 server to run Bolo Kobul exactly as it runs today
# (Ruby 2.6.3, the same gems), with a supported OS, PostgreSQL 16 and Redis 7.
#
# Run as the "ubuntu" user:   bash deploy/new-server/setup.sh
# Safe to run more than once. It does NOT copy data, start the site or install
# scheduled jobs - see README.md for those steps.
set -euo pipefail

APP_ROOT=/home/ubuntu/apps/bolokobul
SHARED=$APP_ROOT/shared
CURRENT=$APP_ROOT/current
REPO_URL=git@github.com:Sharahamid/Bolo-Kobul.git

RUBY_VERSION=2.6.3
# The prebuilt Ruby only works from the folder it was built for, so it lives there and
# /opt/rubies/ruby-2.6.3 (used by the services and PATH) is a shortcut to it
RUBY_HOME=/opt/hostedtoolcache/Ruby/$RUBY_VERSION/x64
RUBY_PREFIX=/opt/rubies/ruby-$RUBY_VERSION
RUBY_URL=https://github.com/ruby/ruby-builder/releases/download/toolcache/ruby-$RUBY_VERSION-ubuntu-24.04.tar.gz
RUBY_SHA256=88a7254921c96feda654f38c964ad174d895df3f11cda9b1425351f8f7d39a77
BUNDLER_VERSION=2.2.21

NODE_VERSION=16.20.2
NODE_PREFIX=/opt/node-$NODE_VERSION
NODE_URL=https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz
NODE_SHA256=874463523f26ed528634580247f403d200ba17a31adf2de98a7b124c6eb33d87

step() { printf '\n\033[1;33m==> %s\033[0m\n' "$*"; }

if [ "$(id -un)" != "ubuntu" ]; then
  echo "Please run this as the ubuntu user (not root)." >&2
  exit 1
fi
# shellcheck source=/dev/null
. /etc/os-release
if [ "$VERSION_ID" != "24.04" ]; then
  echo "This script is for Ubuntu 24.04 (found $PRETTY_NAME)." >&2
  exit 1
fi

step "1/9 System packages"
sudo apt-get update -q
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -q
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
  build-essential g++-11 gcc-11 pkg-config git curl xz-utils rsync \
  libpq-dev libxml2-dev libxslt1-dev libyaml-dev zlib1g-dev libffi-dev shared-mime-info \
  postgresql postgresql-contrib redis-server nginx certbot python3-certbot-nginx \
  imagemagick ghostscript tesseract-ocr tesseract-ocr-eng tesseract-ocr-ben \
  unattended-upgrades
sudo systemctl enable --now postgresql redis-server nginx
sudo dpkg-reconfigure -f noninteractive unattended-upgrades

step "2/9 Swap space (2 GB safety buffer for memory)"
if ! sudo swapon --show | grep -q /swapfile; then
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  grep -q '^/swapfile ' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
  echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null
  sudo sysctl -p /etc/sysctl.d/99-swappiness.conf >/dev/null
fi

step "3/9 Ruby $RUBY_VERSION (same version as the current server)"
if [ ! -x "$RUBY_HOME/bin/ruby" ]; then
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/ruby.tar.gz" "$RUBY_URL"
  echo "$RUBY_SHA256  $tmp/ruby.tar.gz" | sha256sum -c -
  sudo mkdir -p "$(dirname "$RUBY_HOME")"
  sudo tar -xzf "$tmp/ruby.tar.gz" -C "$(dirname "$RUBY_HOME")"
  rm -rf "$tmp"
fi
# Replace any earlier copy at the shortcut location with the shortcut itself
if [ -e "$RUBY_PREFIX" ] && [ ! -L "$RUBY_PREFIX" ]; then
  sudo rm -rf "$RUBY_PREFIX"
fi
sudo mkdir -p "$(dirname "$RUBY_PREFIX")"
sudo ln -sfn "$RUBY_HOME" "$RUBY_PREFIX"
sudo tee /etc/profile.d/bolokobul-ruby.sh >/dev/null <<PROFILE
export PATH=$RUBY_PREFIX/bin:$NODE_PREFIX/bin:\$PATH
PROFILE
export PATH=$RUBY_PREFIX/bin:$NODE_PREFIX/bin:$PATH
sudo "$RUBY_PREFIX/bin/gem" install bundler -v "$BUNDLER_VERSION" --no-document --conservative
ruby -v

step "4/9 Node.js $NODE_VERSION and Yarn (needed to build the site's JavaScript)"
if [ ! -x "$NODE_PREFIX/bin/node" ]; then
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/node.tar.xz" "$NODE_URL"
  echo "$NODE_SHA256  $tmp/node.tar.xz" | sha256sum -c -
  sudo mkdir -p "$NODE_PREFIX"
  sudo tar -xJf "$tmp/node.tar.xz" -C "$NODE_PREFIX" --strip-components=1
  rm -rf "$tmp"
fi
[ -x "$NODE_PREFIX/bin/yarn" ] || sudo env PATH="$NODE_PREFIX/bin:$PATH" npm install -g yarn@1.22.22 --silent
node -v && yarn -v

step "5/9 Folders"
mkdir -p "$SHARED"/{config,log,storage,public/uploads,tmp/pids,tmp/sockets,tmp/cache}
# Ubuntu 24.04 closes home folders to other users; nginx must be able to pass through
# (not list) /home/ubuntu to reach the site's files and the Puma socket
chmod o+x "$HOME"

step "6/9 Website code from GitHub"
if [ ! -d "$CURRENT/.git" ]; then
  # GitHub's test login always exits with code 1, so check its message instead
  github_reply=$(ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)
  if ! grep -q "successfully authenticated" <<< "$github_reply"; then
    echo "This server can't read the GitHub repository yet. Add its deploy key first (README step 3)." >&2
    exit 1
  fi
  git clone "$REPO_URL" "$CURRENT"
fi
# Link the shared folders into the code (log/ and storage/ links are already in the repository)
ln -sfn "$SHARED/public/uploads" "$CURRENT/public/uploads"
for f in application.yml database.yml secrets.yml; do
  ln -sfn "$SHARED/config/$f" "$CURRENT/config/$f"
done

step "7/9 Ruby libraries (gems) - exact versions from Gemfile.lock"
cd "$CURRENT"
# The old sassc library only compiles with GCC 11, so point the compiler names at it for this install
compat=$(mktemp -d)
ln -s /usr/bin/gcc-11 "$compat/gcc"; ln -s /usr/bin/g++-11 "$compat/g++"; ln -s /usr/bin/g++-11 "$compat/c++"
bundle _"$BUNDLER_VERSION"_ config set --local path vendor/bundle
bundle _"$BUNDLER_VERSION"_ config set --local without 'development test'
bundle _"$BUNDLER_VERSION"_ config set --local build.nokogiri --use-system-libraries
PATH="$compat:$PATH" bundle _"$BUNDLER_VERSION"_ install --jobs 2
rm -rf "$compat"

step "8/9 JavaScript packages"
yarn install --frozen-lockfile --non-interactive --silent

step "9/9 Background services (installed now, started after the data is copied)"
sudo cp deploy/new-server/systemd/bolokobul-puma.service deploy/new-server/systemd/bolokobul-sidekiq.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable bolokobul-puma bolokobul-sidekiq

printf '\n\033[1;32mSetup finished.\033[0m Next: copy the data from the old server (README step 5).\n'
