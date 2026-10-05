// Stand-in for the outside services the site calls, used only by the browser tests:
//   - SMS gateway         GET  /sms                     -> "sent" (or HTTP 503 while switched off
//                         with GET /_sms_down?down=1, back on with ?down=0)
//   - aamarPay checkout   POST /aamarpay/payment         -> returns a local "payment page" URL
//   - aamarPay pay page   GET  /aamarpay/pay?tran_id=..  -> posts back to the site like the real gateway
//                         (&outcome=success|fail|cancel, default success)
//   - aamarPay verify     GET  /aamarpay/trxcheck        -> "Successful" for paid transactions
// Start with: node e2e/support/fake_services.js   (port 4599, or FAKE_SERVICES_PORT)
// The site always talks to aamarPay over HTTPS, so set FAKE_SERVICES_CERT and FAKE_SERVICES_KEY
// to a test certificate (and make the site trust it, e.g. via SSL_CERT_FILE) to serve HTTPS.
const http = require('http');
const https = require('https');
const fs = require('fs');
const { URL } = require('url');

const port = Number(process.env.FAKE_SERVICES_PORT || 4599);
const tls = process.env.FAKE_SERVICES_CERT && process.env.FAKE_SERVICES_KEY
  ? { cert: fs.readFileSync(process.env.FAKE_SERVICES_CERT), key: fs.readFileSync(process.env.FAKE_SERVICES_KEY) }
  : null;
const scheme = tls ? 'https' : 'http';
const checkouts = new Map(); // tran_id -> { success_url, fail_url, cancel_url, paid }
const smsLog = [];
let smsDown = false;

function send(res, status, body, type = 'application/json') {
  res.writeHead(status, { 'Content-Type': type });
  res.end(typeof body === 'string' ? body : JSON.stringify(body));
}

function readBody(req) {
  return new Promise((resolve) => {
    let data = '';
    req.on('data', (chunk) => { data += chunk; });
    req.on('end', () => resolve(data));
  });
}

const escapeHtml = (s) => String(s).replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);

const handler = async (req, res) => {
  const url = new URL(req.url, `${scheme}://127.0.0.1:${port}`);

  if (url.pathname === '/sms') {
    if (smsDown) return send(res, 503, 'SMS gateway unavailable', 'text/plain');
    smsLog.push({ to: url.searchParams.get('receiver'), message: url.searchParams.get('message') });
    return send(res, 200, [{ status: 'SUCCESS' }]);
  }

  if (url.pathname === '/aamarpay/payment' && req.method === 'POST') {
    const data = JSON.parse((await readBody(req)) || '{}');
    checkouts.set(data.tran_id, { success_url: data.success_url, fail_url: data.fail_url, cancel_url: data.cancel_url, paid: false });
    return send(res, 200, { result: 'true', payment_url: `${scheme}://127.0.0.1:${port}/aamarpay/pay?tran_id=${encodeURIComponent(data.tran_id)}` });
  }

  if (url.pathname === '/aamarpay/pay') {
    const tranId = url.searchParams.get('tran_id');
    const outcome = url.searchParams.get('outcome') || 'success';
    const checkout = checkouts.get(tranId);
    if (!checkout) return send(res, 404, 'Unknown transaction', 'text/plain');
    if (outcome === 'success') checkout.paid = true;
    const target = checkout[`${outcome}_url`];
    return send(res, 200, `<!doctype html><title>Fake aamarPay</title><body>
      <form id="back" method="post" action="${escapeHtml(target)}">
        <input type="hidden" name="mer_txnid" value="${escapeHtml(tranId)}">
        <input type="hidden" name="pay_status" value="${outcome === 'success' ? 'Successful' : 'Failed'}">
      </form><script>document.getElementById('back').submit();</script></body>`, 'text/html');
  }

  if (url.pathname === '/aamarpay/trxcheck') {
    const checkout = checkouts.get(url.searchParams.get('request_id'));
    return send(res, 200, { pay_status: checkout && checkout.paid ? 'Successful' : 'Failed' });
  }

  if (url.pathname === '/_sms_log') return send(res, 200, smsLog);
  if (url.pathname === '/_sms_down') {
    smsDown = url.searchParams.get('down') === '1';
    return send(res, 200, { smsDown });
  }
  if (url.pathname === '/_health') return send(res, 200, { ok: true });
  return send(res, 404, 'Not found', 'text/plain');
};

(tls ? https.createServer(tls, handler) : http.createServer(handler))
  .listen(port, '127.0.0.1', () => console.log(`Fake services listening on ${scheme}://127.0.0.1:${port}`));
