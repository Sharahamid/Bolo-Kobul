const { test, expect } = require('@playwright/test');
const { login, seed, csrfToken } = require('../support/helpers');

// Members can save a search, run it again in one tap, and delete it.
test.describe('Saved searches', () => {
  test('a member saves a search, runs it again and deletes it', async ({ page }) => {
    const { members } = seed();
    await login(page, 'carol@example.com');
    await page.goto(`/marriage_profiles/${members.carol}/search?age_from=20&age_to=60&locale=en`);

    // The name is filled in from the filters
    await expect(page.locator('#bk-save-name')).toHaveValue('20–60 years');
    await page.locator('#bk-save-name').fill('My test search');
    await Promise.all([page.waitForNavigation(), page.locator('.bk-save-box button').click()]);
    await expect(page.getByText('Search saved as "My test search"')).toBeVisible();
    const chip = page.locator('.bk-saved-chip', { hasText: 'My test search' });
    await expect(chip).toBeVisible();
    // Already saved, so no second save box for the same filters
    await expect(page.locator('.bk-save-box')).toHaveCount(0);

    // One tap runs it again with the same filters
    await page.goto(`/marriage_profiles/${members.carol}/search_page?locale=en`);
    await Promise.all([page.waitForNavigation(), chip.locator('a.bk-saved-run').click()]);
    const url = new URL(page.url());
    expect(url.searchParams.get('age_from')).toBe('20');
    expect(url.searchParams.get('age_to')).toBe('60');

    // Another member cannot open or delete it
    const runHref = await chip.locator('a.bk-saved-run').getAttribute('href');
    await page.context().clearCookies();
    await login(page, 'dave@example.com');
    const other = await page.request.get(runHref, { maxRedirects: 0 });
    expect(other.status()).toBe(404);
    const token = await csrfToken(page);
    const del = await page.request.delete(runHref.replace('/run', ''), { headers: { 'X-CSRF-Token': token }, maxRedirects: 0 });
    expect(del.status()).toBe(404);

    // The owner deletes it
    await page.context().clearCookies();
    await login(page, 'carol@example.com');
    await page.goto(`/marriage_profiles/${members.carol}/search_page?locale=en`);
    await page.locator('.bk-saved-chip', { hasText: 'My test search' }).locator('.bk-saved-del').click();
    await Promise.all([page.waitForNavigation(), page.getByRole('button', { name: 'Yes, Confirm' }).click()]);
    await expect(page.getByText('Saved search deleted.')).toBeVisible();
    await expect(page.locator('.bk-saved-chip', { hasText: 'My test search' })).toHaveCount(0);
  });
});
