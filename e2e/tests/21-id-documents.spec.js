const { test, expect } = require('@playwright/test');
const { seed } = require('../support/helpers');

// ID documents (NID, passport) are private: only admins can open them.
test.describe('ID documents', () => {
  test('admins can open a member\'s ID document; nobody else can', async ({ page, browser }) => {
    const { members } = seed();
    await page.goto('/shefali007/login');
    await page.locator('#admin_user_email').fill(seed().admin);
    await page.locator('#admin_user_password').fill(seed().password);
    await Promise.all([page.waitForNavigation(), page.locator('input[type="submit"]').click()]);

    await page.goto(`/shefali007/marriage_profiles/${members.alice}`);
    const link = page.locator('a[href$="/id_document"]').first();
    await expect(link).toBeAttached();
    const href = await link.getAttribute('href');
    const doc = await page.request.get(href);
    expect(doc.status()).toBe(200);
    expect(doc.headers()['content-type']).toMatch(/^image\//);
    expect(doc.headers()['cache-control']).toContain('no-store');

    // Signed out: no document, only the admin login page
    const stranger = await (await browser.newContext()).newPage();
    const response = await stranger.goto(href);
    await expect(stranger).toHaveURL(/\/shefali007\/login/);
    expect(response.headers()['content-type']).toMatch(/text\/html/);

    // Nothing is served from the old public folder any more
    const old = await stranger.request.get('/uploads/marriage_profile/identification_document/1/test-id-card.png');
    expect(old.status()).toBe(404);
  });
});
