#!/bin/bash
# Lets visitors' phones and browsers keep the library files (Bootstrap, icons, slider) for a
# year instead of downloading them again on every visit. The folder names include the
# version (bootstrap-4.3.1 ...), so a new version always gets a new address.
#
#   Check only (changes nothing):  sudo bash script/nginx_cache_vendor.sh check
#   Make the change:               sudo bash script/nginx_cache_vendor.sh
#
# A copy of the current setting is saved first. If nginx does not accept the new setting,
# the copy is put back automatically and nothing changes.
set -u

CONF=$(grep -l "bolokobul" /etc/nginx/sites-enabled/* 2>/dev/null | head -1)
if [ -z "$CONF" ]; then
  echo "Could not find the Bolo Kobul nginx setting in /etc/nginx/sites-enabled. Nothing changed."
  exit 1
fi
CONF=$(readlink -f "$CONF")
echo "nginx setting file: $CONF"

if grep -q "location \^~ /vendor/" "$CONF"; then
  echo "Already done: library files are already kept by browsers. Nothing to change."
  exit 0
fi

echo "Library files now: $(curl -sI https://bolokobul.com/vendor/bootstrap-4.3.1/bootstrap.min.css | grep -i '^cache-control' || echo 'no Cache-Control (browsers download them every visit)')"

if [ "${1:-}" = "check" ]; then
  echo "Check only: nothing changed. Run without the word check to make the change."
  exit 0
fi

if ! grep -q "^\s*location / {" "$CONF"; then
  echo "Could not find 'location / {' in $CONF. Nothing changed - please send this to Claude."
  exit 1
fi

BACKUP="$HOME/nginx-bolokobul-backup-$(date +%Y%m%d-%H%M%S).conf"
cp "$CONF" "$BACKUP"
echo "Copy saved: $BACKUP"

awk '
  !done && /^[[:space:]]*location \/ \{/ {
    print "    # Library files (Bootstrap, icons, slider): browsers keep them for a year"
    print "    location ^~ /vendor/ {"
    print "        expires 365d;"
    print "        try_files $uri =404;"
    print "    }"
    print ""
    done = 1
  }
  { print }
' "$BACKUP" > "$CONF"

if nginx -t 2>/dev/null; then
  systemctl reload nginx
  sleep 1
  echo "Done. Library files now: $(curl -sI https://bolokobul.com/vendor/bootstrap-4.3.1/bootstrap.min.css | grep -i '^cache-control')"
else
  cp "$BACKUP" "$CONF"
  echo "nginx did not accept the change, so the old setting was put back. Nothing changed - please send this to Claude."
  nginx -t
  exit 1
fi
