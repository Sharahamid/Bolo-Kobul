#!/usr/bin/env bash
# Copies everything the site needs from the old server to this new one, then
# builds and (re)starts the site here. Run it once to test, and again at switch-over.
#
# Run as the "ubuntu" user on the NEW server:
#   bash deploy/new-server/copy-from-old-server.sh 172.31.19.141
# (the old server's PRIVATE IP address). Requires the SSH key from README step 4.
#
# The old server is only READ from - nothing there is changed.
set -euo pipefail

OLD_HOST=${1:?Usage: copy-from-old-server.sh <old server private IP>}
OLD="ubuntu@$OLD_HOST"
SSH_KEY=$HOME/.ssh/old_server
SSH="ssh -i $SSH_KEY -o StrictHostKeyChecking=accept-new"
APP_ROOT=/home/ubuntu/apps/bolokobul
SHARED=$APP_ROOT/shared
CURRENT=$APP_ROOT/current
OLD_SHARED=/home/ubuntu/apps/bolokobul/shared
export PATH=/opt/rubies/ruby-2.6.3/bin:/opt/node-16.20.2/bin:$PATH
export RAILS_ENV=production

step() { printf '\n\033[1;33m==> %s\033[0m\n' "$*"; }

step "1/8 Checking the connection to the old server"
$SSH "$OLD" 'hostname && test -d /home/ubuntu/apps/bolokobul/shared/config'

step "2/8 Settings files"
for f in application.yml database.yml secrets.yml; do
  rsync -a -e "$SSH" "$OLD:$OLD_SHARED/config/$f" "$SHARED/config/$f"
done
chmod 600 "$SHARED/config/"*.yml

step "3/8 Database login for this server"
cd "$CURRENT"
# Read database name and user straight from the settings files (no database needed yet)
DB_INFO=$(ruby -ryaml -rerb -e '
  app = YAML.safe_load(File.read(ARGV[0])) || {}
  app = app.merge(app["production"] || {}) if app["production"].is_a?(Hash)
  app.each { |k, v| ENV[k] = v.to_s unless v.is_a?(Hash) }
  db = (YAML.safe_load(ERB.new(File.read(ARGV[1])).result, aliases: true) || {})["production"] || {}
  puts [db["database"].to_s.empty? ? "bolokobul_production" : db["database"],
        db["username"].to_s.empty? ? "bolokobul" : db["username"]].join(" ")
' "$SHARED/config/application.yml" "$SHARED/config/database.yml")
read -r DB_NAME DB_USER <<< "$DB_INFO"
echo "Database: $DB_NAME   user: $DB_USER"
DB_PASSWORD=$(openssl rand -hex 24)
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1; then
  sudo -u postgres psql -qc "ALTER ROLE \"$DB_USER\" WITH LOGIN PASSWORD '$DB_PASSWORD'"
else
  sudo -u postgres psql -qc "CREATE ROLE \"$DB_USER\" WITH LOGIN PASSWORD '$DB_PASSWORD'"
fi
# The site connects with this (overrides any connection details in database.yml)
sed -i '/^DATABASE_URL:/d' "$SHARED/config/application.yml"
printf "\nDATABASE_URL: 'postgres://%s:%s@127.0.0.1:5432/%s'\n" "$DB_USER" "$DB_PASSWORD" "$DB_NAME" >> "$SHARED/config/application.yml"

step "4/8 Database copy (old server keeps running)"
$SSH "$OLD" "sudo -u postgres pg_dump -Fc '$DB_NAME'" > /tmp/bolokobul.dump
ls -lh /tmp/bolokobul.dump
sudo systemctl stop bolokobul-sidekiq bolokobul-puma 2>/dev/null || true
sudo -u postgres dropdb --if-exists "$DB_NAME"
sudo -u postgres createdb -O "$DB_USER" "$DB_NAME"
# Leave out the two entries PostgreSQL 16 already has (the "public" schema and the
# built-in plpgsql comment); restoring them from the old PostgreSQL 10 only gives errors.
pg_restore -l /tmp/bolokobul.dump | grep -vE ' SCHEMA - public | COMMENT - EXTENSION plpgsql | COMMENT - SCHEMA public ' > /tmp/bolokobul.list
# shellcheck disable=SC2024  # the ubuntu user reads the dump; postgres only restores it
sudo -u postgres pg_restore --no-owner --no-privileges --exit-on-error --role="$DB_USER" -d "$DB_NAME" \
  -L /tmp/bolokobul.list < /tmp/bolokobul.dump
rm -f /tmp/bolokobul.dump /tmp/bolokobul.list
bundle exec rails runner 'puts "Members: #{User.count}, profiles: #{MarriageProfile.count}, orders: #{Order.count}"'

step "5/8 Uploaded photos and documents"
# Follow the old site's links to wherever the files really are
OLD_UPLOADS=$($SSH "$OLD" 'readlink -f /home/ubuntu/apps/bolokobul/current/public/uploads')
OLD_STORAGE=$($SSH "$OLD" 'readlink -f /home/ubuntu/apps/bolokobul/current/storage')
echo "Old server: uploads in $OLD_UPLOADS, storage in $OLD_STORAGE"
rsync -a --delete -e "$SSH" "$OLD:$OLD_UPLOADS/" "$SHARED/public/uploads/"
rsync -a --delete -e "$SSH" "$OLD:$OLD_STORAGE/" "$SHARED/storage/"
du -sh "$SHARED/public/uploads" "$SHARED/storage"

step "6/8 Security certificates (https)"
$SSH "$OLD" 'sudo tar -C /etc -czf - letsencrypt' | sudo tar -C /etc -xzf -
sudo cp "$CURRENT/deploy/new-server/nginx/bolokobul.conf" /etc/nginx/sites-available/bolokobul
sudo ln -sfn /etc/nginx/sites-available/bolokobul /etc/nginx/sites-enabled/bolokobul
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

step "7/8 Building the site's JavaScript and styles"
bundle exec rails assets:precompile 2>&1 | tail -3

step "8/8 Starting the site"
sudo systemctl restart bolokobul-puma bolokobul-sidekiq
sleep 15
code=$(curl -s -o /dev/null -w '%{http_code}' --resolve bolokobul.com:443:127.0.0.1 https://bolokobul.com/)
echo "Home page on this server: HTTP $code"
[ "$code" = "200" ] || { echo "Not 200 - check: sudo journalctl -u bolokobul-puma -n 50" >&2; exit 1; }

printf '\n\033[1;32mThis server is running a copy of Bolo Kobul.\033[0m\n'
echo "Scheduled jobs are NOT installed here yet (that happens at switch-over)."
