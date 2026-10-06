const { test, expect } = require('@playwright/test');
const { login, seed, csrfToken } = require('../support/helpers');

// Google Play requires that members can report and block other members.
// Dave and Erin are only used here.
test.describe('Report & Block', () => {
  test('a member reports and blocks a profile; both stop seeing each other and the chat closes', async ({ page }) => {
    const { members, unique_ids } = seed();
    await login(page, 'dave@example.com');
    await page.goto(`/marriage_profiles/${members.erin}/profile_info`);

    await page.getByRole('button', { name: 'Report & Block' }).click();
    const modal = page.locator('#bk-report-modal');
    await expect(modal).toBeVisible();
    await expect(modal).toContainText(unique_ids.erin);

    // A reason must be chosen; "Something else" also needs a few words
    const submit = modal.locator('#bk-report-submit');
    await expect(submit).toBeDisabled();
    await modal.getByText('Something else').click();
    await expect(submit).toBeDisabled();
    await modal.locator('#bk-report-details').fill('Asked me to send money for a visa.');
    await expect(submit).toBeEnabled();
    await expect(submit).toHaveText('Report & Block');

    await Promise.all([page.waitForNavigation(), submit.click()]);
    await expect(page.getByText(`We've received your report and blocked ${unique_ids.erin}`)).toBeVisible();

    // Dave no longer sees Erin's profile, and she is in his blocked list where he can unblock
    await page.goto(`/marriage_profiles/${members.erin}/profile_info`);
    await expect(page.getByText('This profile is not available.')).toBeVisible();
    await page.goto('/marriage_profiles/blocked_profiles');
    await expect(page.getByText(unique_ids.erin)).toBeVisible();

    // Erin can't see Dave or message him, and can't undo his block
    await page.context().clearCookies();
    await login(page, 'erin@example.com');
    await page.goto(`/marriage_profiles/${members.dave}/profile_info`);
    await expect(page.getByText('This profile is not available.')).toBeVisible();
    await page.goto(`/messages/${members.dave}/profile`);
    await expect(page).not.toHaveURL(/\/messages\/.*\/profile/);
    await page.goto('/marriage_profiles/blocked_profiles');
    await expect(page.getByText('No blocked profiles')).toBeVisible();
    const token = await csrfToken(page);
    await page.request.patch(`/marriage_profiles/${members.dave}/unblock_profile`, { headers: { 'X-CSRF-Token': token } });
    await page.goto(`/marriage_profiles/${members.dave}/profile_info`);
    await expect(page.getByText('This profile is not available.')).toBeVisible();

    // Dave unblocks: they can see each other again
    await page.context().clearCookies();
    await login(page, 'dave@example.com');
    await page.goto('/marriage_profiles/blocked_profiles');
    await page.getByRole('link', { name: 'Unblock' }).click();
    await Promise.all([page.waitForNavigation(), page.getByRole('button', { name: 'Yes, Confirm' }).click()]);
    await expect(page.getByText('Unblocked Successfully')).toBeVisible();
    await page.goto(`/marriage_profiles/${members.erin}/profile_info`);
    await expect(page.getByRole('button', { name: 'Report & Block' })).toBeVisible();
  });

  test('a member can report without blocking, and the report reaches the admin panel', async ({ page }) => {
    const { members, unique_ids } = seed();
    await login(page, 'dave@example.com');
    await page.goto(`/marriage_profiles/${members.carol}/profile_info`);
    await page.getByRole('button', { name: 'Report & Block' }).click();
    const modal = page.locator('#bk-report-modal');
    await modal.getByText('Fake profile or false information').click();
    await modal.getByText('Also block this profile').click();
    await expect(modal.locator('#bk-report-submit')).toHaveText('Send Report');
    await Promise.all([page.waitForNavigation(), modal.locator('#bk-report-submit').click()]);
    await expect(page.getByText(`We've received your report about ${unique_ids.carol}`)).toBeVisible();
    // Not blocked
    await page.goto(`/marriage_profiles/${members.carol}/profile_info`);
    await expect(page.getByRole('button', { name: 'Report & Block' })).toBeVisible();

    await page.context().clearCookies();
    await page.goto('/shefali007/login');
    await page.locator('#admin_user_email').fill(seed().admin);
    await page.locator('#admin_user_password').fill(seed().password);
    await Promise.all([page.waitForNavigation(), page.locator('input[type="submit"]').click()]);
    await page.goto('/shefali007/profile_reports');
    await expect(page.locator('table.index_table')).toContainText(unique_ids.carol);
    await expect(page.locator('table.index_table')).toContainText('Fake profile or false information');
    await expect(page.locator('table.index_table')).toContainText(unique_ids.erin);
  });
});
