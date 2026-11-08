const { test, expect } = require('@playwright/test');
const { seed } = require('../support/helpers');

test.describe('Admin panel', () => {
  test('an admin can log in and open the main admin pages', async ({ page }) => {
    await page.goto('/shaheer10inara20/login');
    await page.locator('#admin_user_email').fill(seed().admin);
    await page.locator('#admin_user_password').fill(seed().password);
    await Promise.all([page.waitForNavigation(), page.locator('input[type="submit"]').click()]);
    await expect(page).toHaveURL(/\/shaheer10inara20\/?$/);

    for (const path of ['/shaheer10inara20/users', '/shaheer10inara20/marriage_profiles', '/shaheer10inara20/orders', '/shaheer10inara20/admin_users']) {
      const response = await page.goto(path);
      expect(response.status(), path).toBe(200);
    }
  });

  test('members cannot open the admin panel', async ({ page }) => {
    await page.goto('/shaheer10inara20');
    await expect(page).toHaveURL(/\/shaheer10inara20\/login/);
  });
});
