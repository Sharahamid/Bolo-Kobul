const { test, expect } = require('@playwright/test');
const { login, seed } = require('../support/helpers');

const ajax = { 'X-Requested-With': 'XMLHttpRequest', Accept: 'text/javascript, */*' };

test.describe('Profiles: members can only change their own', () => {
  test.beforeEach(async ({ page }) => login(page, 'alice@example.com'));

  test("viewing another member's public profile works", async ({ page }) => {
    const response = await page.goto(`/marriage_profiles/${seed().members.bob}/profile_info`);
    expect(response.status()).toBe(200);
  });

  test('editing her own profile works', async ({ page }) => {
    const response = await page.request.get(`/marriage_profiles/${seed().members.alice}/edit`, { headers: ajax });
    expect(response.status()).toBe(200);
  });

  for (const action of ['edit', 'edit_about', 'switch', 'dashboard']) {
    test(`cannot open "${action}" on another member's profile`, async ({ page }) => {
      const response = await page.request.get(`/marriage_profiles/${seed().members.bob}/${action}`, { headers: ajax, maxRedirects: 0 });
      expect(response.status()).toBe(404);
    });
  }

  test("cannot edit another member's family or education details", async ({ page }) => {
    const { bob_family_member_id: family, bob_academic_information_id: education } = seed();
    expect((await page.request.get(`/family_members/${family}/edit`, { headers: ajax })).status()).toBe(404);
    expect((await page.request.get(`/academic_informations/${education}/edit`, { headers: ajax })).status()).toBe(404);
  });

  test('switching to her own profile still works', async ({ page }) => {
    await page.goto(`/marriage_profiles/${seed().members.alice}/switch`);
    await expect(page).toHaveURL(new RegExp(`/marriage_profiles/${seed().members.alice}/profile_info`));
  });
});
