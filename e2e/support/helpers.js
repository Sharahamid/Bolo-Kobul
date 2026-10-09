const fs = require('fs');
const path = require('path');
const { expect } = require('@playwright/test');

const FAKE_SERVICES = process.env.E2E_FAKE_SERVICES_URL || 'http://127.0.0.1:4599';

function seed() {
  return JSON.parse(fs.readFileSync(path.join(__dirname, '.seed.json'), 'utf8'));
}

async function login(page, email, password = seed().password) {
  await page.goto('/');
  const form = page.locator('form[action="/users/sign_in"]');
  // The form is in the LOGIN pop-up window
  if (!(await form.locator('input[name="user[login]"]').isVisible())) {
    await page.locator('a[data-target="#loginModal"]:visible').first().click();
    await form.locator('input[name="user[login]"]').waitFor({ state: 'visible' });
  }
  await form.locator('input[name="user[login]"]').fill(email);
  await form.locator('input[name="user[password]"]').fill(password);
  await Promise.all([page.waitForNavigation(), form.locator('input[type="submit"]').click()]);
}

async function csrfToken(page) {
  return page.locator('meta[name="csrf-token"]').getAttribute('content');
}

// Collects uncaught JavaScript errors on a page so tests can assert there were none
function trackPageErrors(page) {
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  return errors;
}

async function smsLog(request) {
  const response = await request.get(`${FAKE_SERVICES}/_sms_log`);
  expect(response.ok()).toBeTruthy();
  return response.json();
}

// Fills in the sign-up form on the home page and returns the new member's details.
// Ends on the "enter your verification code" page.
async function registerNewMember(page, { name = 'Test Member', createdFor = 'self' } = {}) {
  const unique = `${Date.now()}`.slice(-7);
  const member = { name, unique, email: `new${unique}@example.com`, phone: `+880171${unique}`, password: 'dhaka2024' };
  await page.goto('/');
  const form = page.locator('form#new_user').first();
  await form.locator('input[name="user[name]"]').fill(member.name);
  await form.locator('input[name="user[email]"]').fill(member.email);
  // Bangladesh (+880) is already chosen in the country list, so the number is typed the local way
  await form.locator('input[name="user[phone_number]"]').fill(`0171${unique}`);
  await form.locator('input[name="user[password]"]').fill(member.password);
  await form.locator('input[name="user[password_confirmation]"]').fill(member.password);
  await form.locator('select[name="user[created_for]"]').selectOption(createdFor);
  await form.locator('input[type="checkbox"][required]').check();
  await Promise.all([page.waitForNavigation(), form.locator('input[type="submit"]').click()]);
  await expect(page).toHaveURL(/show_verify/);
  member.verifyUrl = page.url();
  return member;
}

// The most recent verification code texted to a phone number (via the stand-in SMS gateway)
async function latestCode(request, member) {
  const sms = (await smsLog(request)).reverse().find((entry) => entry.to && entry.to.includes(member.unique));
  expect(sms, 'verification SMS sent').toBeTruthy();
  return sms.message.match(/code is (\d{6})/)[1];
}

async function submitCode(page, code) {
  await page.locator('input[name="token"]').fill(code);
  await Promise.all([page.waitForNavigation(), page.locator('button[type="submit"]', { hasText: 'Verify' }).click()]);
}

module.exports = { FAKE_SERVICES, seed, login, csrfToken, trackPageErrors, smsLog, registerNewMember, latestCode, submitCode };
