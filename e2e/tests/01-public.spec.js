const { test, expect } = require('@playwright/test');
const { trackPageErrors, smsLog } = require('../support/helpers');

test.describe('Public pages', () => {
  test('home page loads with sign-up and login forms and no JavaScript errors', async ({ page }) => {
    const errors = trackPageErrors(page);
    await page.goto('/');
    await expect(page).toHaveTitle(/Bolokobul/);
    await expect(page.locator('form#new_user input[name="user[name]"]').first()).toBeVisible();
    await expect(page.locator('form[action="/users/sign_in"] input[name="user[login]"]')).toHaveCount(1);
    expect(errors).toEqual([]);
  });

  test('link previews and app (PWA) files are in place', async ({ page, request }) => {
    await page.goto('/');
    await expect(page.locator('meta[property="og:image"]')).toHaveAttribute('content', /\/og-image\.png$/);
    await expect(page.locator('link[rel="manifest"]')).toHaveAttribute('href', '/manifest.json');

    const manifest = await (await request.get('/manifest.json')).json();
    expect(manifest.short_name).toBe('Bolo Kobul');
    expect(manifest.icons.map((icon) => icon.sizes)).toEqual(expect.arrayContaining(['192x192', '512x512']));
    for (const file of ['/og-image.png', '/service-worker.js', '/offline.html', '/icons/icon-512.png']) {
      expect((await request.get(file)).status(), file).toBe(200);
    }
  });

  test('a new member can register with a Bangla name and verify by SMS code', async ({ page, request }) => {
    const unique = Date.now().toString().slice(-7);
    const phone = `+880171${unique}`;
    await page.goto('/');
    const form = page.locator('form#new_user').first();
    await form.locator('input[name="user[name]"]').fill('শারা হামিদ');
    await form.locator('input[name="user[email]"]').fill(`new${unique}@example.com`);
    await form.locator('input[name="user[phone_number]"]').fill(phone);
    await form.locator('input[name="user[password]"]').fill('dhaka2024');
    await form.locator('input[name="user[password_confirmation]"]').fill('dhaka2024');
    await form.locator('select[name="user[created_for]"]').selectOption('self');
    await form.locator('input[type="checkbox"][required]').check();
    await Promise.all([page.waitForNavigation(), form.locator('input[type="submit"]').click()]);

    await expect(page).toHaveURL(/show_verify/);
    const sms = (await smsLog(request)).reverse().find((entry) => entry.to && entry.to.includes(unique));
    expect(sms, 'verification SMS sent').toBeTruthy();
    const code = sms.message.match(/code is (\d{6})/)[1];

    await page.locator('input[name="token"]').fill(code);
    await Promise.all([page.waitForNavigation(), page.locator('button[type="submit"]', { hasText: 'Verify' }).click()]);
    await expect(page).not.toHaveURL(/show_verify/);
    await expect(page.locator('a[href="/users/sign_out"], [href*="sign_out"]').first()).toBeAttached();
  });

  test('registration rejects a weak password', async ({ page }) => {
    await page.goto('/');
    const form = page.locator('form#new_user').first();
    const password = form.locator('input[name="user[password]"]');
    await password.fill('short');
    expect(await password.evaluate((input) => input.checkValidity())).toBe(false);
    await password.fill('dhaka2024');
    expect(await password.evaluate((input) => input.checkValidity())).toBe(true);
  });
});
