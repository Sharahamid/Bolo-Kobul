const { test, expect } = require('@playwright/test');
const { seed } = require('../support/helpers');

// "Continue with Google". Only runs when the local site fakes Google (E2E_SOCIAL_LOGIN=1).
async function continueWithGoogle(page, email) {
  await page.context().addCookies([{ name: 'bk_e2e_social_email', value: email, url: page.url() }]);
  await page.locator('a[data-target="#loginModal"]:visible').first().click();
  await Promise.all([page.waitForNavigation(), page.locator('#loginModal').getByRole('button', { name: 'Continue with Google' }).click()]);
}

test.describe('Social login', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    test.skip(await page.locator('.bk-social-btn--google_oauth2').count() === 0, 'Google login is not set up on this site');
  });

  test('an existing member with the same email is logged straight in', async ({ page }) => {
    await continueWithGoogle(page, 'alice@example.com');
    await expect(page.getByText('Signed in with Google.')).toBeVisible();
    await expect(page).toHaveURL(new RegExp(`/marriage_profiles/${seed().members.alice}/dashboard`));
  });

  test('a new person adds a mobile number, then verifies it by SMS code', async ({ page }) => {
    const email = `new-${Date.now()}@example.com`;
    await continueWithGoogle(page, email);
    await expect(page).toHaveURL(/\/users\/social-signup/);
    await expect(page.getByText(`as ${email}`)).toBeVisible();

    await page.locator('#user_phone_number').fill(`+88017${String(Date.now()).slice(-8)}`);
    await page.locator('#user_created_for').selectOption('self');
    await page.locator('.bk-social-signup__terms input').check();
    await Promise.all([page.waitForNavigation(), page.getByRole('button', { name: 'Continue' }).click()]);
    await expect(page).toHaveURL(/show_verify/);
  });
});
