# Moving Bolo Kobul to a new server

The current server runs Ubuntu 18.04 and PostgreSQL 10, both past end of support.
This kit builds a **new Ubuntu 24.04 server** that runs the website with PostgreSQL 16 and
Redis 7, then switches visitors over by moving the Elastic IP address. Nothing changes for
members except a few minutes of maintenance. (The move itself was done on Ruby 2.6.3; see
"Upgrading Ruby and Rails" below for later upgrades.)

The old server is only ever **read from**, so it stays as an instant fallback.

| Step | Where | Time | Website affected? |
|---|---|---|---|
| 1. Create the new server | AWS console | 10 min | No |
| 2. Connect with PuTTY | Your PC | 5 min | No |
| 3. Let it read the code (deploy key) | New server + GitHub | 5 min | No |
| 4. Let it read the old server (SSH key) | Both servers | 5 min | No |
| 5. Run the setup | New server | 20–30 min | No |
| 6. Copy the data and test | New server | 10 min + testing | No |
| 7. Switch-over | All | ~15 min | **Yes, brief maintenance** |
| 8. Undo, if ever needed | AWS console | 1 min | — |

---

## 1. Create the new server (AWS console, region **Asia Pacific (Singapore)**)

**EC2 → Instances → Launch instances**

| Setting | Value |
|---|---|
| Name | `bolokobul-2026` |
| Application and OS image | **Ubuntu Server 24.04 LTS**, 64-bit (x86) |
| Instance type | `t3.medium` (same size as today) |
| Key pair | your existing key (the one you use with PuTTY) |
| Network settings → Firewall | **Create security group** named `bolokobul-web`, allowing **SSH**, **HTTPS** and **HTTP** from Anywhere |
| Configure storage | **30 GiB, gp3** |

Click **Launch instance**. When it shows **Running**, note its **Public IPv4 address**.

## 2. Connect with PuTTY

As with the old server, but **Host Name** = `ubuntu@<new public IP>`, with the same `.ppk` key.

## 3. Let the new server read the code from GitHub

On the **new** server:

```bash
ssh-keygen -t ed25519 -N "" -C bolokobul-new-server -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Copy the line it prints. On GitHub: **Sharahamid/Bolo-Kobul → Settings → Deploy keys → Add deploy key**.
Title `New server 2026`, paste the key, leave **Allow write access unticked**, click **Add key**.

Check it works (it should say *successfully authenticated*):

```bash
ssh -o StrictHostKeyChecking=accept-new -T git@github.com
```

## 4. Let the new server read from the old one

On the **new** server, make a key just for copying:

```bash
ssh-keygen -t ed25519 -N "" -C copy-from-old -f ~/.ssh/old_server
cat ~/.ssh/old_server.pub
```

On the **old** server, add that line to the allowed keys (replace the text in quotes with the line you copied):

```bash
echo "ssh-ed25519 AAAA...paste...the...line... copy-from-old" >> ~/.ssh/authorized_keys
```

Both servers are in the same AWS network, so the new one reaches the old one on its **private IP**
(`172.31.19.141`). Check from the **new** server (it should print the old server's name):

```bash
ssh -i ~/.ssh/old_server -o StrictHostKeyChecking=accept-new ubuntu@172.31.19.141 hostname
```

## 5. Run the setup (new server)

```bash
git clone git@github.com:Sharahamid/Bolo-Kobul.git /tmp/bolokobul-setup
bash /tmp/bolokobul-setup/deploy/new-server/setup.sh
```

It installs everything (system updates, PostgreSQL, Redis, nginx, Ruby, Node, the site's
libraries) and prints **Setup finished** at the end. It is safe to run again if it stops part-way.

## 6. Copy the data and test (new server)

```bash
cd ~/apps/bolokobul/current
bash deploy/new-server/copy-from-old-server.sh 172.31.19.141
```

It copies the database, photos and documents, settings and security certificates, builds the site and
starts it. It ends with **Home page on this server: HTTP 200**.
**Scheduled jobs are deliberately not installed yet**, so emails and SMS aren't sent twice.

### Testing it in your browser before anyone else sees it

Point **only your own computer** at the new server:

1. On Windows, open **Notepad as administrator** and open `C:\Windows\System32\drivers\etc\hosts`.
2. Add these two lines at the bottom (using the new server's public IP) and save:
   ```
   <new public IP>  bolokobul.com
   <new public IP>  www.bolokobul.com
   ```
3. Open bolokobul.com in a **private/incognito** window. You are now on the new server; everyone else
   is still on the old one.

**Check:** home page, logging in, profiles, photos, your dashboard, the admin panel, chat between **your own**
test accounts. **Avoid** sending Kobuls to or messaging real members, and avoid payments: this copy is
thrown away at switch-over, but SMS, emails and phone notifications it sends are real.

When done, **remove the two lines** from the hosts file again.

## 7. Switch-over (a quiet time, e.g. 2–4 am Bangladesh time)

**a. Backup snapshot** of the **old** server's volume (EC2 → Volumes → Actions → Create snapshot).

**b. Stop the old site** (old server). Visitors see an error page for the next few minutes:

```bash
crontab -l > ~/crontab-before-switch.txt && crontab -r
kill $(pgrep -f "sidekiq 5.2.8") 2>/dev/null; kill $(pgrep -f "puma 4.3.0") 2>/dev/null; sleep 5
pgrep -af "puma|sidekiq" || echo "old site stopped"
```

**c. Final data copy** (new server). Re-copies everything, so no recent change is lost:

```bash
cd ~/apps/bolokobul/current && git pull --ff-only && bash deploy/new-server/copy-from-old-server.sh 172.31.19.141
```

**d. Move the address:** EC2 → **Elastic IPs** → select the address (`52.76.139.89`) → **Actions →
Associate Elastic IP address** → Instance: **bolokobul-2026** → tick **Allow this Elastic IP address to be
reassociated** → **Associate**. Visitors reach the new server within seconds.

**e. Turn on scheduled jobs** (new server), exactly once each:

```bash
cd ~/apps/bolokobul/current && bundle exec whenever --update-crontab bolokobul --set environment=production && crontab -l
```

**f. Check:** open bolokobul.com normally (hosts-file lines removed). Log in, open a profile, send a chat
message between two of your accounts.

Keep the old server **running but stopped as a website** for a week, then shut it down.

## 8. Undo (if something is wrong after switch-over)

1. EC2 → Elastic IPs → **Associate** the address back to the **old** instance (tick *Allow reassociation*).
2. On the old server, start the site again (`cd ~/apps/bolokobul/current && bundle exec puma -C config/puma.rb -d`
   and `bundle exec sidekiq -d -e production -L log/sidekiq.log`) and restore its schedule:
   `crontab ~/crontab-before-switch.txt`.

Anything members did on the new server in the meantime would need copying back, so decide quickly.

---

## Everyday commands on the new server

| Task | Command |
|---|---|
| Update to the latest code | `cd ~/apps/bolokobul/current && git pull --ff-only && bundle exec rails db:migrate && bundle exec rails assets:precompile && sudo systemctl reload bolokobul-puma && sudo systemctl restart bolokobul-sidekiq` |
| Restart the website | `sudo systemctl restart bolokobul-puma` |
| Website status / recent errors | `sudo systemctl status bolokobul-puma` · `sudo journalctl -u bolokobul-puma -n 50` |
| Background jobs status | `sudo systemctl status bolokobul-sidekiq` |

The website and background jobs now **start automatically after a reboot**.

## Upgrading Ruby and Rails

When an upgrade changes the Ruby version (`.ruby-version`), take an AWS snapshot first
(EC2 → Instances → the server → Storage → volume → Actions → Create snapshot), then:

```bash
grep -c SECRET_KEY_BASE ~/apps/bolokobul/shared/config/application.yml   # should print 1
cd ~/apps/bolokobul/current && git pull --ff-only && bash deploy/new-server/setup.sh
source /etc/profile.d/bolokobul-ruby.sh && ruby -v
bundle exec rails db:migrate && bundle exec rails assets:precompile
sudo systemctl restart bolokobul-puma bolokobul-sidekiq
sleep 20 && curl -s -o /dev/null -w 'Home page: HTTP %{http_code}\n' https://bolokobul.com/
```

`setup.sh` installs the new Ruby and its libraries next to the old ones and points
`/opt/rubies/current` at it. The running site keeps using the old Ruby until the `restart`,
which takes it offline for about 20 seconds. Members stay signed in.

**Undo** (the old Ruby and its libraries stay in place):

```bash
cd ~/apps/bolokobul/current && git checkout <commit before the upgrade>
sudo ln -sfn /opt/hostedtoolcache/Ruby/<old version>/x64 /opt/rubies/current
source /etc/profile.d/bolokobul-ruby.sh && bundle exec rails assets:precompile
sudo systemctl restart bolokobul-puma bolokobul-sidekiq
```

| Upgrade | Ruby | Rails | Commit before it |
|---|---|---|---|
| October 2026 | 2.7.8 → 3.4.6 | 6.1 → 8.1 | `9ffb4bd` |
