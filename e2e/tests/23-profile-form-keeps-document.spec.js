const path = require('path');
const { test, expect } = require('@playwright/test');
const { registerNewMember, latestCode, submitCode } = require('../support/helpers');

// If the Basics form comes back with an error, the ID document already chosen is kept
test('the ID document is kept when the profile form comes back with an error', async ({ page, request }) => {
  const member = await registerNewMember(page, { name: 'Doc Keeper', createdFor: 'parents' });
  await submitCode(page, await latestCode(request, member));
  await page.goto('/marriage_profiles/new?locale=en');

  const form = page.locator('form#new_marriage_profile, form[action="/marriage_profiles"]').first();
  const pick = async (name, value) => form.locator(`select[name="marriage_profile[${name}]"]`).selectOption(value);
  await form.locator('input[name="marriage_profile[name]"]').fill('Candidate Test');
  await form.locator('input[name="marriage_profile[identification_document]"]').setInputFiles(path.join(__dirname, '..', 'fixtures', 'test-id-card.png'));
  await form.locator('input[name="marriage_profile[nid_or_passport]"]').fill('TESTNID0003'); // already used by a seeded member
  await pick('gender', 'female');
  await form.locator('input[name="marriage_profile[date_of_birth]"]').fill('1996-04-12');
  await pick('marital_status', 'unmarried');
  await pick('religion', 'islam');
  await pick('hometown', 'Dhaka');
  await pick('present_location', 'Dhaka');
  await pick('height_ft', '5');
  await pick('height_inch', '4');
  await pick('highest_education_level', 'graduate');
  for (const name of ['family_type', 'family_status', 'family_values', 'blood_group']) {
    await form.locator(`select[name="marriage_profile[${name}]"]`).selectOption({ index: 1 });
  }
  await Promise.all([page.waitForNavigation(), form.locator('button[type="submit"]').click()]);

  // Back on the form with the NID error, but the document is kept
  await expect(page.locator('body')).toContainText(/already been taken/i);
  await expect(page.getByText(/Document uploaded: test-id-card\.png/)).toBeVisible();
  await expect(page.locator('input[name="marriage_profile[identification_document]"]')).not.toHaveAttribute('required', /.*/);

  // Fix only the NID and send again: the profile is created with the kept document
  await page.locator('input[name="marriage_profile[nid_or_passport]"]').fill(`DOC${member.unique}`);
  await Promise.all([page.waitForNavigation(), page.locator('form button[type="submit"]').first().click()]);
  await expect(page).toHaveURL(/partner_preferences\/new/);
});

// After uploading a photo the page reloads by itself and shows it
test('uploading a profile photo reloads the page and shows the photo', async ({ page }) => {
  const { login, seed } = require('../support/helpers');
  await login(page, 'alice@example.com');
  await page.goto(`/marriage_profiles/${seed().members.alice}/profile_info`);
  await page.locator('#js-photo-upload-1').setInputFiles(path.join(__dirname, '..', 'fixtures', 'test-id-card.png'));
  // The success message shows first, then the page reloads by itself
  await expect(page.getByText(/Photo uploaded successfully/).first()).toBeVisible();
  await page.waitForEvent('load');
  await expect(page.locator('#marriage_profile_photos img.small-thumbnail').first()).toBeVisible();
});

// Fills in the whole Basics form for a candidate
async function fillBasics(page, nid) {
  await page.goto('/marriage_profiles/new?locale=en');
  const form = page.locator('form[action="/marriage_profiles"]').first();
  const pick = async (name, value) => form.locator(`select[name="marriage_profile[${name}]"]`).selectOption(value);
  await form.locator('input[name="marriage_profile[name]"]').fill('Candidate Back');
  await form.locator('input[name="marriage_profile[identification_document]"]').setInputFiles(path.join(__dirname, '..', 'fixtures', 'test-id-card.png'));
  await form.locator('input[name="marriage_profile[nid_or_passport]"]').fill(nid);
  await pick('gender', 'female');
  await form.locator('input[name="marriage_profile[date_of_birth]"]').fill('1996-04-12');
  await pick('marital_status', 'unmarried');
  await pick('religion', 'islam');
  await pick('hometown', 'Dhaka');
  await pick('present_location', 'Dhaka');
  await pick('height_ft', '5');
  await pick('height_inch', '4');
  await pick('highest_education_level', 'graduate');
  for (const name of ['family_type', 'family_status', 'family_values', 'blood_group']) {
    await form.locator(`select[name="marriage_profile[${name}]"]`).selectOption({ index: 1 });
  }
  await Promise.all([page.waitForNavigation(), form.locator('button[type="submit"]').click()]);
}

test('going Back from Preferences and pressing Next again does not say the NID is taken', async ({ page, request }) => {
  const member = await registerNewMember(page, { name: 'Back Tester', createdFor: 'parents' });
  await submitCode(page, await latestCode(request, member));
  await fillBasics(page, `BACK${member.unique}`);
  await expect(page).toHaveURL(/partner_preferences\/new/);

  // "Looking For" is fixed (the opposite gender), and there is one "Doesn't Matter" per list
  await expect(page.locator('.bk-fixed-choice')).toHaveText('Groom');
  await expect(page.locator('select[name="partner_preference[gender]"]')).toHaveCount(0);
  for (const name of ['physical_status', 'family_type', 'family_status', 'family_values']) {
    await expect(page.locator(`select[name="partner_preference[${name}]"] option[value="does_not_matter"]`)).toHaveCount(0);
  }

  // Back to the Basics form, same details again
  await fillBasics(page, `BACK${member.unique}`);
  await expect(page.locator('body')).not.toContainText(/already been taken/i);
  await expect(page).toHaveURL(/partner_preferences\/new/);
});
