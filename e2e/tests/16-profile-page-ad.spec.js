const { test, expect } = require('@playwright/test');
const { login, seed } = require('../support/helpers');

// "Profile page" ads from Admin > Ads: beside the photos on computers, below the
// profile details on phones. The dashboard ads in the side column stay as they are.
test('the profile-page ad shows beside the photos, and the side-column ads stay', async ({ browser }) => {
  const { members } = seed();
  const computer = await (await browser.newContext({ viewport: { width: 1366, height: 900 } })).newPage();
  await login(computer, 'alice@example.com');
  await computer.goto(`/marriage_profiles/${members.bob}/profile_info`);
  await expect(computer.locator('.bk-photos-ad-row').getByAltText('E2E Profile ad')).toBeVisible();
  await expect(computer.locator('.left-sidebar-section').getByAltText('E2E Partner ad')).toBeVisible();
  await expect(computer.locator('.left-sidebar-section').getByAltText('E2E Profile ad')).toHaveCount(0);

  const phone = await (await browser.newContext({ viewport: { width: 390, height: 844 }, isMobile: true })).newPage();
  await phone.context().addCookies(await computer.context().cookies());
  await phone.goto(`/marriage_profiles/${members.bob}/profile_info`);
  await expect(phone.locator('.bk-profile-ad--inline').getByAltText('E2E Profile ad')).toBeVisible();
  await expect(phone.locator('.bk-profile-ad--beside-photos')).toBeHidden();

  // The dashboard has no profile-page ad
  await computer.goto(`/marriage_profiles/${members.alice}/dashboard`);
  await expect(computer.getByAltText('E2E Partner ad')).toBeVisible();
  await expect(computer.getByAltText('E2E Profile ad')).toHaveCount(0);
});
