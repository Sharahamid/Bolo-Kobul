const { test, expect } = require('@playwright/test');
const { registerNewMember, latestCode, submitCode } = require('../support/helpers');

// A parent, relative or friend creating a profile is asked about "the candidate", not "you"
test.describe('Profile form wording', () => {
  test('a parent creating a profile sees "Candidate\'s ..." in English and Bangla', async ({ page, request }) => {
    const member = await registerNewMember(page, { name: 'Parent Tester', createdFor: 'parents' });
    await submitCode(page, await latestCode(request, member));

    await page.goto('/marriage_profiles/new?locale=en');
    await expect(page.locator('.internal_form_heading')).toHaveText("Great! Let's create the candidate's profile");
    await expect(page.locator('input[name="marriage_profile[name]"]')).toHaveAttribute('placeholder', "Candidate's Full Name");
    await expect(page.locator('input[name="marriage_profile[nid_or_passport]"]')).toHaveAttribute('placeholder', "Candidate's NID or Passport No.");

    await page.goto('/marriage_profiles/new?locale=bn');
    await expect(page.locator('.internal_form_heading')).toHaveText('চলুন, পাত্র/পাত্রীর প্রোফাইল তৈরি করি');
    await expect(page.locator('input[name="marriage_profile[name]"]')).toHaveAttribute('placeholder', 'পাত্র/পাত্রীর পূর্ণ নাম');
  });

  test('a member creating their own profile still sees "your profile"', async ({ page, request }) => {
    const member = await registerNewMember(page, { name: 'Self Tester' });
    await submitCode(page, await latestCode(request, member));
    await page.goto('/marriage_profiles/new?locale=en');
    await expect(page.locator('.internal_form_heading')).toHaveText("Great! Let's create your profile");
    await expect(page.locator('input[name="marriage_profile[name]"]')).toHaveAttribute('placeholder', 'Full Name');
  });
});

test.describe('Partner preference wording', () => {
  test('preferences say Preferred Hometown / Present Location, Minimum Education Level and Doesn\'t Matter', async ({ page }) => {
    const { login } = require('../support/helpers');
    await login(page, 'alice@example.com');
    await page.goto('/partner_preferences?locale=en');
    const form = page.locator('form');
    for (const text of ['Preferred Hometown', 'Preferred Present Location', 'Minimum Education Level']) {
      await expect(form.locator('label', { hasText: text }).first()).toBeVisible();
    }
    await expect(page.locator('.filter-option-inner-inner', { hasText: "Doesn't Matter" }).first()).toBeVisible();
    await expect(page.getByText('Nothing selected')).toHaveCount(0);
  });
});
