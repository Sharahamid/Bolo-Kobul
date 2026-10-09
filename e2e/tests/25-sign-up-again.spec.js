const { test, expect } = require('@playwright/test');
const { registerNewMember, latestCode, submitCode } = require('../support/helpers');

async function fillSignUp(page, { name, email, phone, password = 'dhaka2024' }) {
  await page.goto('/?locale=en');
  const form = page.locator('form#new_user').first();
  await form.locator('input[name="user[name]"]').fill(name);
  await form.locator('input[name="user[email]"]').fill(email);
  await form.locator('input[name="user[phone_number]"]').fill(phone);
  await form.locator('input[name="user[password]"]').fill(password);
  await form.locator('input[name="user[password_confirmation]"]').fill(password);
  await form.locator('select[name="user[created_for]"]').selectOption('self');
  await form.locator('input[type="checkbox"][required]').check();
  await Promise.all([page.waitForNavigation(), form.locator('input[type="submit"]').click()]);
}

// Someone who signed up but never entered the code can simply sign up again
test.describe('Signing up again', () => {
  test('an unfinished sign-up does not block the same email and number', async ({ page, request }) => {
    const first = await registerNewMember(page, { name: 'Again Tester' });
    await page.context().clearCookies();

    // Same email (different case) and the same number typed the local way
    await fillSignUp(page, { name: 'Again Tester', email: first.email.toUpperCase(), phone: `0171${first.unique}` });
    await expect(page).toHaveURL(/show_verify/);
    await expect(page.getByText('has already been taken')).toHaveCount(0);

    await submitCode(page, await latestCode(request, first));
    await expect(page).not.toHaveURL(/show_verify/);
  });

  test('a verified member\'s email and number still cannot be used again', async ({ page }) => {
    await fillSignUp(page, { name: 'Copy Cat', email: 'alice@example.com', phone: '+8801711000001' });
    await expect(page).not.toHaveURL(/show_verify/);
    await expect(page.getByText('has already been taken').first()).toBeVisible();
  });
});
