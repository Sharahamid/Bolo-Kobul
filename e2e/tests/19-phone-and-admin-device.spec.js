const fs = require('fs');
const path = require('path');
const { test, expect } = require('@playwright/test');
const { seed, login, smsLog, registerNewMember, latestCode, submitCode } = require('../support/helpers');

test.describe('Phone numbers in any format', () => {
  test('a number is saved once, texted in local form, and works for log-in however it is typed', async ({ page, request, browser }) => {
    const member = await registerNewMember(page, { name: 'Spaced Phone' });
    // The code went to the gateway as 0171XXXXXXX, not with +880 or spaces
    const sms = (await smsLog(request)).reverse().find((entry) => entry.to && entry.to.includes(member.unique));
    expect(sms.to).toBe(`0171${member.unique}`);
    await submitCode(page, await latestCode(request, member));

    // The same number typed the local way cannot open a second account
    const other = await browser.newContext();
    const otherPage = await other.newPage();
    await otherPage.goto('/');
    const form = otherPage.locator('form#new_user').first();
    await form.locator('input[name="user[name]"]').fill('Duplicate Phone');
    await form.locator('input[name="user[email]"]').fill(`dup${member.unique}@example.com`);
    await form.locator('input[name="user[phone_number]"]').fill(`0171 ${member.unique}`);
    await form.locator('input[name="user[password]"]').fill('dhaka2024');
    await form.locator('input[name="user[password_confirmation]"]').fill('dhaka2024');
    await form.locator('select[name="user[created_for]"]').selectOption('self');
    await form.locator('input[type="checkbox"][required]').check();
    await form.locator('input[type="submit"]').click();
    await expect(otherPage.locator('body')).toContainText(/already been taken/i);
    await expect(otherPage).not.toHaveURL(/show_verify/);

    // Logging in with the local form of the number finds the account
    const third = await browser.newContext();
    const thirdPage = await third.newPage();
    await login(thirdPage, `0171${member.unique}`, member.password);
    await expect(thirdPage.locator('body')).not.toContainText('Invalid email or password');
    await other.close();
    await third.close();
  });
});

test.describe('Admin new-device email', () => {
  const mailFile = () => path.join(__dirname, '..', '..', 'tmp', 'mails', seed().admin);
  const sentCount = () => {
    try { return (fs.readFileSync(mailFile(), 'utf8').match(/Subject: New sign-in to the Bolo Kobul admin panel/g) || []).length; } catch (e) { return 0; }
  };
  const adminLogin = async (page) => {
    await page.goto('/shefali007/login');
    await page.locator('#admin_user_email').fill(seed().admin);
    await page.locator('#admin_user_password').fill(seed().password);
    await Promise.all([page.waitForNavigation(), page.locator('input[type="submit"]').click()]);
    await expect(page).toHaveURL(/\/shefali007\/?$/);
  };

  test('signing in from a new browser emails the admin once', async ({ browser }) => {
    const before = sentCount();
    const context = await browser.newContext();
    const page = await context.newPage();
    await adminLogin(page);
    await expect.poll(sentCount, { timeout: 15000 }).toBe(before + 1);

    // Signing out and in again on the same browser sends nothing new
    const deviceCookie = (await context.cookies()).filter((c) => c.name === 'bk_admin_device');
    expect(deviceCookie.length).toBe(1);
    await context.clearCookies();
    await context.addCookies(deviceCookie);
    await adminLogin(page);
    await page.waitForTimeout(2000);
    expect(sentCount()).toBe(before + 1);
    await context.close();
  });
});
