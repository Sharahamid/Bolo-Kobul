#!/bin/bash
# Security update of named libraries (gems), run on the server when the weekly Security scan
# reports one. Only the named gems move up, by the smallest safe step; everything else stays.
#
#   bash script/update_gems.sh puma msgpack omniauth
#
# 1. Saves a copy of Gemfile.lock in your home folder
# 2. Updates the named gems and installs them
# 3. Restarts the site and checks it answers
# 4. Prints the change: send that part to Claude so GitHub gets the same file
# If anything fails, the old Gemfile.lock is put back and nothing changes.
set -u
if [ $# -eq 0 ]; then echo "Usage: bash script/update_gems.sh <gem names>"; exit 1; fi
cd ~/apps/bolokobul/current

BACKUP="$HOME/Gemfile.lock.backup-$(date +%Y%m%d-%H%M%S)"
cp Gemfile.lock "$BACKUP"
echo "Copy saved: $BACKUP"

restore() {
  cp "$BACKUP" Gemfile.lock
  echo "Something went wrong, so the old Gemfile.lock was put back. Nothing changed - please send this to Claude."
  exit 1
}

echo "Updating: $* ..."
bundle lock --update "$@" --conservative || restore
echo "Installing..."
bundle install --quiet || restore

sudo systemctl restart bolokobul-puma
sleep 8
CODE=$(curl -s -o /dev/null -w '%{http_code}' https://bolokobul.com/about)
if [ "$CODE" != "200" ]; then
  echo "The site answered $CODE after the update - putting the old versions back..."
  cp "$BACKUP" Gemfile.lock
  bundle install --quiet
  sudo systemctl restart bolokobul-puma
  echo "Old versions are back. Please send this to Claude."
  exit 1
fi

echo "Site is up (answer $CODE)."
echo
echo "===== Send everything below this line to Claude ====="
git diff --no-color Gemfile.lock
echo "===== End ====="
