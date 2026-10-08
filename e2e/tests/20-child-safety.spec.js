const { test, expect } = require('@playwright/test');
const { login, seed } = require('../support/helpers');

// Google Play requires dating and social apps to publish child safety standards
// and to let members report child safety concerns in the app.
test.describe('Child safety', () => {
  test('the Child Safety Standards page is public and linked from the footer', async ({ page }) => {
    const response = await page.goto('/child-safety');
    expect(response.status()).toBe(200);
    await expect(page.locator('h1')).toHaveText('Child Safety Standards');
    await expect(page.locator('body')).toContainText('zero tolerance for child sexual abuse and exploitation');
    await expect(page.locator('footer a[href="/child-safety"], a[href="/child-safety"]').first()).toBeAttached();
  });

  test('Report & Block offers an "Under 18 or child safety concern" reason', async ({ page }) => {
    const { members } = seed();
    await login(page, 'alice@example.com');
    await page.goto(`/marriage_profiles/${members.carol}/profile_info`);
    await page.getByRole('button', { name: 'Report & Block' }).click();
    await expect(page.locator('#bk-report-modal')).toContainText('Under 18 or child safety concern');
  });
});
