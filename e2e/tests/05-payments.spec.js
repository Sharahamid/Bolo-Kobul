const { test, expect } = require('@playwright/test');
const { login } = require('../support/helpers');

test.describe('Payments (with a stand-in aamarPay)', () => {
  test('buying butterflies returns the member logged in with the purchase confirmed', async ({ browser }) => {
    const page = await (await browser.newContext()).newPage();
    await login(page, 'alice@example.com');
    await page.goto('/orders/new');
    const form = page.locator('form[action="/orders"]');
    await form.locator('[name="order[quantity]"]').fill('2');

    await Promise.all([
      page.waitForURL((url) => url.pathname.startsWith('/marriage_profiles/'), { timeout: 60_000 }),
      form.locator('button[type="submit"]').click()
    ]);
    await expect(page.getByText(/Purchase successful/i).first()).toBeVisible();

    await page.goto('/orders');
    await expect(page.locator('.orders-section').getByText(/success/i).first()).toBeVisible();
  });

  test('a forged payment return does not log anyone in', async ({ browser }) => {
    // Alice starts a checkout; then a stranger posts a fake "success" return without the secret token
    const alice = await (await browser.newContext()).newPage();
    await login(alice, 'alice@example.com');
    await alice.goto('/orders/new');
    const form = alice.locator('form[action="/orders"]');
    await form.locator('[name="order[quantity]"]').fill('1');
    let returnUrl;
    alice.on('request', (request) => {
      if (request.method() === 'POST' && /\/orders\/\d+\/success/.test(request.url())) returnUrl = request;
    });
    await Promise.all([alice.waitForURL(/marriage_profiles/, { timeout: 60_000 }), form.locator('button[type="submit"]').click()]);
    expect(returnUrl, 'gateway posted back to the site').toBeTruthy();

    const target = new URL(returnUrl.url());
    const txn = new URLSearchParams(returnUrl.postData()).get('mer_txnid');
    target.searchParams.delete('rt'); // the secret return token

    const stranger = await (await browser.newContext()).newPage();
    await stranger.request.post(target.toString(), { form: { mer_txnid: txn } });
    const after = await stranger.goto('/orders');
    expect(after.url()).not.toMatch(/\/orders$/); // still logged out, sent away from members-only page
  });
});
