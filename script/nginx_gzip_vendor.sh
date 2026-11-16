#!/bin/bash
# Squeezes the library style files (Bootstrap, icons, slider) before sending them, like the
# site's own files already are: about 240 KB becomes about 40 KB, so phones show the page
# sooner. Needs script/nginx_cache_vendor.sh to have been run first.
#
#   Check only (changes nothing):  sudo bash script/nginx_gzip_vendor.sh check
#   Make the change:               sudo bash script/nginx_gzip_vendor.sh
#
# A copy of the current setting is saved first. If nginx does not accept the new setting,
# the copy is put back automatically and nothing changes.
set -u

CONF=$(grep -l "bolokobul" /etc/nginx/sites-enabled/* 2>/dev/null | head -1)
if [ -z "$CONF" ]; then
  echo "Could not find the Bolo Kobul nginx setting. Nothing changed."
  exit 1
fi
CONF=$(readlink -f "$CONF")
URL=https://bolokobul.com/vendor/bootstrap-4.3.1/bootstrap.min.css
size() { curl -s -H 'Accept-Encoding: gzip' -o /dev/null -w '%{size_download}' "$URL"; }

if ! grep -q "location \^~ /vendor/ {" "$CONF"; then
  echo "Please run script/nginx_cache_vendor.sh first. Nothing changed."
  exit 1
fi
if grep -q "# Library files are squeezed" "$CONF"; then
  echo "Already done. Bootstrap style file now downloads as $(( $(size) / 1024 )) KB."
  exit 0
fi

echo "Bootstrap style file now downloads as $(( $(size) / 1024 )) KB."
if [ "${1:-}" = "check" ]; then
  echo "Check only: nothing changed. Run without the word check to make the change."
  exit 0
fi

BACKUP="$HOME/nginx-bolokobul-backup-$(date +%Y%m%d-%H%M%S).conf"
cp "$CONF" "$BACKUP"
echo "Copy saved: $BACKUP"

awk '
  { print }
  !done && /location \^~ \/vendor\/ \{/ {
    print "        # Library files are squeezed before sending (much smaller downloads)"
    print "        gzip on;"
    print "        gzip_vary on;"
    print "        gzip_comp_level 6;"
    print "        gzip_types text/css application/javascript image/svg+xml;"
    done = 1
  }
' "$BACKUP" > "$CONF"

if nginx -t 2>/dev/null; then
  systemctl reload nginx
  sleep 1
  echo "Done. Bootstrap style file now downloads as $(( $(size) / 1024 )) KB."
else
  cp "$BACKUP" "$CONF"
  echo "nginx did not accept the change, so the old setting was put back. Nothing changed - please send this to Claude."
  nginx -t
  exit 1
fi
