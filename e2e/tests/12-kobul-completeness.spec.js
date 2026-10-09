const { test, expect } = require('@playwright/test');
const { login, seed, csrfToken } = require('../support/helpers');

// New members see recommendations straight away; sending a Kobul needs an 80% complete profile
test.describe('Profile completeness and Kobuls', () => {
  test('recommendations show below 80%, but sending a Kobul asks to complete the profile', async ({ page }) => {
    const { members } = seed();
    await login(page, 'dave@example.com');
    // Dave has a chat whose other member was deleted: the dashboard and messages still open
    expect((await page.goto(`/marriage_profiles/${members.dave}/dashboard`)).status()).toBe(200);
    expect((await page.goto('/messages')).status()).toBe(200);
    await page.goto(`/marriage_profiles/${members.dave}/dashboard`);
    await expect(page.locator('.bk-kobul-unlock')).toContainText('Reach 80% to send Kobuls.');
    await expect(page.getByText('to get recommendations')).toHaveCount(0);
    // The sidebar lists the sections still to fill in as short links (no percentages)
    const todo = page.locator('.bk-todo');
    await expect(todo).toContainText('Complete your profile');
    await expect(todo.locator('.bk-todo-link', { hasText: 'Education' })).toHaveCount(1);
    await expect(todo.locator('.bk-todo-link', { hasText: 'Family Details' })).toHaveCount(1);
    await expect(todo).not.toContainText('%');
    // A link opens that section's form on the profile page
    await todo.locator('.bk-todo-link', { hasText: 'Occupation' }).click();
    await expect(page).toHaveURL(/profile_info#update-occupation$/);
    await expect(page.locator('#global_update_modal_sm')).toBeVisible();
    await page.goto(`/marriage_profiles/${members.dave}/dashboard`);

    const token = await csrfToken(page);
    const response = await page.request.post(`/marriage_profiles/${members.carol}/send_request`, { headers: { 'X-CSRF-Token': token } });
    expect(await response.text()).toContain('Complete at least 80% of your profile to send a Kobul');
    // No Kobul was sent
    await page.goto(`/marriage_profiles/${members.carol}/profile_info`);
    await expect(page.getByText('Kobul (1)')).toBeVisible();
  });
});
