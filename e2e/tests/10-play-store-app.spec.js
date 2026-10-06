const { test, expect } = require('@playwright/test');
const { login, seed } = require('../support/helpers');

// Google Play's payments policy: inside the Play Store app (opened at /?source=play),
// butterflies can't be bought or advertised. The website itself is unchanged.
test.describe('Play Store app', () => {
  test('hides butterfly purchases in the app but not on the website', async ({ browser }) => {
    const web = await (await browser.newContext()).newPage();
    await login(web, 'alice@example.com');
    const dashboard = `/marriage_profiles/${seed().members.alice}/dashboard`;

    // Website: Get More and the butterfly offer ad are there, and the purchase page opens
    await web.goto(dashboard);
    await expect(web.getByRole('link', { name: 'Get More' }).first()).toBeVisible();
    await expect(web.locator('.ads-right-sidebar img[src*="ss_BK"]').first()).toBeVisible();
    await web.goto('/orders/new');
    await expect(web).toHaveURL(/\/orders\/new/);

    // App: opened at /?source=play -> dashboard, no Get More, balance still shown
    const app = await (await browser.newContext()).newPage();
    await app.context().addCookies(await web.context().cookies());
    await app.goto('/?source=play');
    await expect(app).toHaveURL(/dashboard/);
    await expect(app.locator('html')).toHaveClass(/bk-play/);
    await expect(app.getByText('Balance').first()).toBeVisible();
    for (const link of await app.getByRole('link', { name: 'Get More' }).all()) await expect(link).toBeHidden();
    // The butterfly offer ad is hidden; partner ads (e.g. wedding photographers) still show
    await expect(app.locator('.ads-right-sidebar img[src*="ss_BK"]').first()).toBeHidden();
    await expect(app.locator('.ads-right-sidebar img[src*="ad_BK"]').first()).toBeVisible();

    // Still the app on later pages in the same session; the purchase page is not available
    await app.goto(dashboard);
    for (const link of await app.getByRole('link', { name: 'Get More' }).all()) await expect(link).toBeHidden();
    await app.goto('/orders/new');
    await expect(app).not.toHaveURL(/\/orders\/new/);

    // The website in another tab is unaffected
    await web.goto(dashboard);
    await expect(web.getByRole('link', { name: 'Get More' }).first()).toBeVisible();
  });
});
