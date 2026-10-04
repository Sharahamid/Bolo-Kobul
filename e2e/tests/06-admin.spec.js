const { test, expect } = require('@playwright/test');
const { seed } = require('../support/helpers');

test.describe('Admin panel', () => {
  test('an admin can log in and open the main admin pages', async ({ page }) => {
    await page.goto('/shefali007/login');
    await page.locator('#admin_user_email').fill(seed().admin);
    await page.locator('#admin_user_password').fill(seed().password);
    await Promise.all([page.waitForNavigation(), page.locator('input[type="submit"]').click()]);
    await expect(page).toHaveURL(/\/shefali007\/?$/);

    for (const path of ['/shefali007/users', '/shefali007/marriage_profiles', '/shefali007/orders', '/shefali007/admin_users']) {
      const response = await page.goto(path);
      expect(response.status(), path).toBe(200);
    }
  });

  test('members cannot open the admin panel', async ({ page }) => {
    await page.goto('/shefali007');
    await expect(page).toHaveURL(/\/shefali007\/login/);
  });
});
