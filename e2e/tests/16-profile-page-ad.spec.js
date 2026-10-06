const { test, expect } = require('@playwright/test');
const { login, seed } = require('../support/helpers');

// "Profile page" ads from Admin > Ads show on members' profile pages
test('the profile-page ad shows beside the profile on computers and below it on phones', async ({ browser }) => {
  const { members } = seed();
  const computer = await (await browser.newContext({ viewport: { width: 1366, height: 900 } })).newPage();
  await login(computer, 'alice@example.com');
  await computer.goto(`/marriage_profiles/${members.bob}/profile_info`);
  await expect(computer.locator('.left-sidebar-section').getByAltText('E2E Profile ad')).toBeVisible();
  await expect(computer.getByText('Sponsored').first()).toBeVisible();

  const phone = await (await browser.newContext({ viewport: { width: 390, height: 844 }, isMobile: true })).newPage();
  await phone.context().addCookies(await computer.context().cookies());
  await phone.goto(`/marriage_profiles/${members.bob}/profile_info`);
  await expect(phone.locator('.bk-profile-ad--inline').getByAltText('E2E Profile ad')).toBeVisible();
  await expect(phone.locator('.left-sidebar-section .bk-profile-ad')).toBeHidden();

  // The dashboard keeps its own ads
  await computer.goto(`/marriage_profiles/${members.alice}/dashboard`);
  await expect(computer.getByAltText('E2E Partner ad')).toBeVisible();
  await expect(computer.getByAltText('E2E Profile ad')).toHaveCount(0);
});
