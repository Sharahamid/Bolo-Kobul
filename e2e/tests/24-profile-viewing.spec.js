const { test, expect } = require('@playwright/test');
const { login, seed } = require('../support/helpers');

// Looking at someone else's profile from the dashboard
test.describe('Viewing a profile', () => {
  test('cards open the profile directly; the match is next to the profile ID', async ({ page }) => {
    const { members, unique_ids } = seed();
    await login(page, 'bob@example.com');
    // Profile cards no longer pop the photo up before opening the profile
    await page.goto('/?locale=en');
    expect(await page.locator('[onclick*="bkOpenPhoto"]').count()).toBe(0);

    await page.goto(`/marriage_profiles/${members.carol}/profile_info?locale=en`);
    const idRow = page.locator('.left-sidebar-card span', { hasText: unique_ids.carol }).first().locator('..');
    await expect(idRow.locator('.bk-match-badge')).toHaveText(/⭐ \d+% Match/);
  });

  test('the photo viewer stops the page scrolling and Back closes it', async ({ page }) => {
    const { members } = seed();
    await login(page, 'bob@example.com');
    const profileUrl = `/marriage_profiles/${members.carol}/profile_info?locale=en`;
    await page.goto(profileUrl);
    const modal = page.locator('#bk-photo-modal');

    await page.evaluate(() => bkOpenPhoto('/favicon.ico'));
    await expect(modal).toBeVisible();
    expect(await page.evaluate(() => getComputedStyle(document.body).overflow)).toBe('hidden');

    // The phone's Back button closes the photo and stays on the profile
    await page.goBack();
    await expect(modal).toBeHidden();
    await expect(page).toHaveURL(new RegExp(`/marriage_profiles/${members.carol}/profile_info`));
    expect(await page.evaluate(() => getComputedStyle(document.body).overflow)).not.toBe('hidden');

    // Tapping the photo also closes it, and Back then leaves the profile as usual
    await page.evaluate(() => bkOpenPhoto('/favicon.ico'));
    await modal.click();
    await expect(modal).toBeHidden();
    await expect(page).toHaveURL(new RegExp(`/marriage_profiles/${members.carol}/profile_info`));
  });

  test('edit forms show each question above its answer', async ({ page }) => {
    const { members } = seed();
    await login(page, 'bob@example.com');
    await page.goto(`/marriage_profiles/${members.bob}/profile_info?locale=en#update-appearance`);
    const modal = page.locator('#global_update_modal_sm');
    await expect(modal).toBeVisible();
    for (const question of ['Body Type', 'Complexion', 'Eye Wear']) {
      await expect(modal.locator('.bk-auto-label', { hasText: question })).toBeVisible();
    }
  });
});
