const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { registerNewMember, latestCode, submitCode, smsLog } = require('../support/helpers');

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

  test('random-letter names from bots are refused, real names are not', async ({ page }) => {
    for (const name of ['Ywdlbvm Yydzr', 'Atxhzm Yybnzlx']) {
      const unique = `${Date.now()}`.slice(-7);
      await fillSignUp(page, { name, email: `bot${unique}@example.com`, phone: `+880171${unique}` });
      await expect(page.getByText('does not appear to be a real name').first()).toBeVisible();
    }
    const unique = `${Date.now()}`.slice(-7);
    await fillSignUp(page, { name: 'Rhythm Khan', email: `rhythm${unique}@example.com`, phone: `+880171${unique}` });
    await expect(page).toHaveURL(/show_verify/);
  });

  test('a verified member\'s email and number still cannot be used again', async ({ page }) => {
    await fillSignUp(page, { name: 'Copy Cat', email: 'alice@example.com', phone: '+8801711000001' });
    await expect(page).not.toHaveURL(/show_verify/);
    await expect(page.getByText('has already been taken').first()).toBeVisible();
  });

  test('a number from outside Bangladesh needs its country code, and gets the code by email', async ({ page, request }) => {
    const unique = `${Date.now()}`.slice(-7);
    const email = `abroad${unique}@example.com`;

    // Without + and the country code it is refused with a clear message (bots send these)
    await fillSignUp(page, { name: 'Abroad Tester', email, phone: `647${unique}` });
    await expect(page).not.toHaveURL(/show_verify/);
    await expect(page.getByText(/start with \+ and the country code/).first()).toBeVisible();

    const phone = `+1 647${unique}`; // a Canadian number
    const mailFile = path.join(__dirname, '../../tmp/mails', email);
    await fillSignUp(page, { name: 'Abroad Tester', email, phone });
    await expect(page).toHaveURL(/show_verify/);

    expect((await smsLog(request)).some((entry) => entry.to && entry.to.includes(unique))).toBe(false);
    await expect.poll(() => fs.existsSync(mailFile)).toBe(true);
    const code = fs.readFileSync(mailFile, 'utf8').match(/>\s*(\d{6})\s*</)[1];
    await submitCode(page, code);
    await expect(page).not.toHaveURL(/show_verify/);
  });
});
