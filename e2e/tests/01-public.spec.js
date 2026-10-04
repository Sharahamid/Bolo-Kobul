const { test, expect } = require('@playwright/test');
const { trackPageErrors, registerNewMember, latestCode, submitCode } = require('../support/helpers');

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
    const member = await registerNewMember(page, { name: 'শারা হামিদ' });
    await submitCode(page, await latestCode(request, member));
    await expect(page).not.toHaveURL(/show_verify/);
    await expect(page.locator('[href*="sign_out"]').first()).toBeAttached();
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
