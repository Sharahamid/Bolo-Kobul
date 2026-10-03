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

module.exports = { FAKE_SERVICES, seed, login, csrfToken, trackPageErrors, smsLog };
