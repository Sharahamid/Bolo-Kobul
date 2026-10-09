const { test, expect } = require('@playwright/test');
const { login } = require('../support/helpers');

// Google Play requires that members can delete their account. Carol is used so the
// other tests' members are never affected.
test.describe('Account deletion', () => {
  test('a member can schedule deletion with their password, sees the date, and can cancel', async ({ page }) => {
    await login(page, 'carol@example.com');
    await page.goto('/privacy_settings');
    const box = page.locator('#delete-account');
    await expect(box).toContainText('Delete my account permanently');

    // Wrong password: nothing happens
    await box.locator('input[name="password"]').fill('not-my-password');
    await box.locator('input[name="confirm_deletion"]').check();
    await box.locator('button[type="submit"]').click();
    // The site's own confirmation box
    await Promise.all([page.waitForNavigation(), page.getByRole('button', { name: 'Yes, Confirm' }).click()]);
    await expect(page.getByText('Please enter your correct password')).toBeVisible();
    await expect(box).toContainText('Delete my account permanently');

    // Right password: scheduled in 30 days, banner on every page
    await box.locator('input[name="password"]').fill('Test1234pass');
    await box.locator('input[name="confirm_deletion"]').check();
    await box.locator('button[type="submit"]').click();
    // The site's own confirmation box
    await Promise.all([page.waitForNavigation(), page.getByRole('button', { name: 'Yes, Confirm' }).click()]);
    const date = new Date(Date.now() + 30 * 24 * 3600 * 1000).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric', timeZone: 'UTC' });
    await expect(box).toContainText(`Will be deleted on ${date}`);
    await page.goto('/blogs');
    await expect(page.getByText('Your account will be deleted permanently on')).toBeVisible();
    // Let the page's photos finish loading first, so no late response sets the sign-in cookie again
    await page.waitForLoadState('networkidle');

    // Logging in again still works, and Cancel deletion restores the account
    await page.context().clearCookies();
    await login(page, 'carol@example.com');
    await Promise.all([page.waitForNavigation(), page.getByRole('link', { name: 'Cancel deletion' }).first().click()]);
    await expect(page.getByText('Your account will be deleted permanently on')).toHaveCount(0);
    await page.goto('/privacy_settings');
    await expect(page.locator('#delete-account')).toContainText('Delete my account permanently');
  });

  test('the public page explains how to delete an account, without logging in', async ({ page }) => {
    const response = await page.goto('/delete-account');
    expect(response.status()).toBe(200);
    await expect(page.getByRole('heading', { name: 'Delete your Bolo Kobul account' })).toBeVisible();
    await expect(page.getByText('erased permanently after 30 days')).toBeVisible();
  });
});
