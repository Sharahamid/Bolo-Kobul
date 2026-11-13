#!/bin/bash
# Brings the server up to date with GitHub for every file changed since commit BASE.
# Safety check first: each of those files on the server must match one of the known
# versions (from BASE onwards); if any file was changed some other way, nothing is touched.
# Usage (on the server):  bash script/update_server.sh <BASE commit>
set -e
BASE="$1"
if [ -z "$BASE" ]; then echo "Usage: bash script/update_server.sh <commit>"; exit 1; fi
cd ~/apps/bolokobul/current
git fetch -q origin
FILES=$(git diff --name-only "$BASE^" origin/main | grep -v '^db/schema.rb$')
COMMITS="$(git rev-list "$BASE^"..origin/main) $(git rev-parse "$BASE^")"
BAD=""
for f in $FILES; do
  ok=0
  for c in $COMMITS; do
    if git diff --quiet "$c" -- "$f" 2>/dev/null; then ok=1; break; fi
  done
  [ "$ok" = 1 ] || BAD="$BAD $f"
done
if [ -n "$BAD" ]; then
  echo "STOP: nothing changed. These files on the server differ from every known version:$BAD"
  exit 1
fi
echo "Updating $(echo $FILES | wc -w) files..."
git checkout origin/main -- $FILES
RAILS_ENV=production bundle exec rails db:migrate
# Design (stylesheet/image/script) changes only show after the assets are rebuilt
if echo "$FILES" | grep -q '^app/assets/\|^app/javascript/'; then
  echo "Rebuilding the design files (takes a minute)..."
  RAILS_ENV=production bundle exec rails assets:precompile
fi
# Daily/weekly tasks: refresh the schedule when config/schedule.rb changed
if echo "$FILES" | grep -q '^config/schedule.rb$'; then
  bundle exec whenever --update-crontab bolokobul --set environment=production
fi
sudo systemctl restart bolokobul-puma
echo "DONE"
