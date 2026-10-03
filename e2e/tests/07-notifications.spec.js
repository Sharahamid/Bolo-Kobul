const { test, expect } = require('@playwright/test');
const { login, csrfToken } = require('../support/helpers');

test.describe('Phone notification subscriptions', () => {
  test('saving a device only works for real push services', async ({ page }) => {
    await login(page, 'alice@example.com');
    const headers = { 'X-CSRF-Token': await csrfToken(page), 'Content-Type': 'application/json' };
    const keys = { p256dh: 'BOtestkey', auth: 'testauth' };

    const blocked = await page.request.post('/push_subscriptions', { headers, data: { endpoint: 'https://169.254.169.254/latest', keys } });
    expect(blocked.status()).toBe(422);

    const endpoint = `https://fcm.googleapis.com/fcm/send/e2e-${Date.now()}`;
    const saved = await page.request.post('/push_subscriptions', { headers, data: { endpoint, keys } });
    expect(saved.status()).toBe(201);

    const removed = await page.request.delete('/push_subscriptions', { headers, data: { endpoint } });
    expect(removed.status()).toBe(204);
  });

  test('logged-out visitors cannot save a device', async ({ request }) => {
    const response = await request.post('/push_subscriptions', {
      data: { endpoint: 'https://fcm.googleapis.com/fcm/send/x', keys: { p256dh: 'a', auth: 'b' } },
      maxRedirects: 0
    });
    expect(response.status()).not.toBe(201);
  });
});
