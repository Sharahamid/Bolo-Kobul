# Browser tests (end-to-end)

Automated checks that click through Bolo Kobul in a real browser (Chromium, via Playwright).
They are the safety net for upgrades: run them before and after every change.

> **Never run these against the live site.** They create members, orders and messages.
> `playwright.config.js` refuses any URL containing `bolokobul.com`.

## What is covered

| File | Checks |
|---|---|
| `01-public.spec.js` | Home page loads without JavaScript errors; link previews and app (PWA) files; sign-up with a Bangla name and SMS verification code; password rules |
| `02-login.spec.js` | Login, wrong password, members-only pages |
| `03-profile-security.spec.js` | Members can view others' profiles but cannot edit, switch to or open the dashboard of them, or change their family or education details |
| `04-chat.spec.js` | Messages appear live for the other member; outsiders cannot post into a chat |
| `05-payments.spec.js` | Full butterfly purchase through a stand-in aamarPay; a forged payment return does not log anyone in |
| `06-admin.spec.js` | Admin login and main admin pages; members cannot open the admin panel |
| `07-notifications.spec.js` | Phone notification subscriptions only accept real push services |

## How it works

- **Test members**: `support/seed.rb` creates made-up members (`alice@`, `bob@`, `carol@example.com`) and an
  admin (`admin@example.com`) before every run. It refuses to run in production.
- **Outside services**: `support/fake_services.js` stands in for the SMS gateway and aamarPay, so no real SMS
  is sent and no real payment is taken. The site's `config/secrets.yml` (git-ignored) must point `sms.url`,
  `aamarpay.payment_url` and `aamarpay.trxcheck_url` at it.
- The site talks to aamarPay over HTTPS, so the stand-in needs a test certificate the site trusts.

## Running locally

```bash
# 1. Test certificate for the stand-in (once)
mkdir -p /tmp/e2e-certs && cd /tmp/e2e-certs
openssl req -x509 -newkey rsa:2048 -nodes -keyout fake.key -out fake.crt -days 30 \
  -subj "/CN=127.0.0.1" -addext "subjectAltName=IP:127.0.0.1,DNS:localhost"
cat /etc/ssl/certs/ca-certificates.crt fake.crt > ca-bundle-with-fake.pem

# 2. Stand-in services (separate terminal, from the project root)
FAKE_SERVICES_CERT=/tmp/e2e-certs/fake.crt FAKE_SERVICES_KEY=/tmp/e2e-certs/fake.key \
  node e2e/support/fake_services.js

# 3. The site in development mode, single process (live chat needs one process in development)
SSL_CERT_FILE=/tmp/e2e-certs/ca-bundle-with-fake.pem \
  bundle exec puma -C /dev/null -w 0 -t 5:5 -b tcp://127.0.0.1:3000 -e development config.ru

# 4. The tests
cd e2e && npm install
E2E_FAKE_SERVICES_URL=https://127.0.0.1:4599 npx playwright test
```

Settings (environment variables):

| Variable | Default |
|---|---|
| `E2E_BASE_URL` | `http://127.0.0.1:3000` |
| `E2E_FAKE_SERVICES_URL` | `http://127.0.0.1:4599` |
| `E2E_SEED_COMMAND` | `bundle exec rails runner e2e/support/seed.rb` |

Failed tests keep a screenshot and a trace in `e2e/test-results/`; open a trace with
`npx playwright show-trace <path>/trace.zip`.
