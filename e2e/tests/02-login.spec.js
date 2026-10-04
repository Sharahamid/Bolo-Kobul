const { test, expect } = require('@playwright/test');
const { login, seed } = require('../support/helpers');

test.describe('Login', () => {
  test('a member can log in and lands on their dashboard', async ({ page }) => {
    await login(page, 'alice@example.com');
    await expect(page).toHaveURL(new RegExp(`/marriage_profiles/${seed().members.alice}/dashboard`));
  });

  test('opening the app (or the home page) while signed in shows the dashboard, not sign-up', async ({ page }) => {
    await login(page, 'alice@example.com');
    for (const url of ['/?source=app', '/']) {
      await page.goto(url);
      await expect(page).toHaveURL(new RegExp(`/marriage_profiles/${seed().members.alice}/dashboard`));
      await expect(page.getByText('Register Now')).toHaveCount(0);
    }
  });

  test('a wrong password is refused', async ({ page }) => {
    await login(page, 'alice@example.com', 'wrong-password-1');
    await expect(page).not.toHaveURL(/dashboard/);
    await expect(page.getByText('Invalid email or password.').first()).toBeVisible();
  });

  test('members-only pages require logging in', async ({ page }) => {
    await page.goto('/orders');
    await expect(page).not.toHaveURL(/\/orders$/);
  });
});
