const { test, expect } = require('@playwright/test');
const { registerNewMember, latestCode, submitCode, seed, csrfToken } = require('../support/helpers');

test.describe('Sign-up verification codes', () => {
  test('after 5 wrong guesses even the right code is refused until a new one is sent', async ({ page, request }) => {
    const member = await registerNewMember(page);
    const code = await latestCode(request, member);
    const wrong = code === '000000' ? '111111' : '000000';

    for (let attempt = 1; attempt <= 5; attempt += 1) {
      await submitCode(page, wrong);
      await expect(page.getByText('Incorrect code, please try again').first()).toBeVisible();
    }
    await submitCode(page, code);
    await expect(page).toHaveURL(/show_verify/);
    await expect(page.getByText(/Too many incorrect attempts/).first()).toBeVisible();
  });

  test('a code works only once', async ({ page, request, browser }) => {
    const member = await registerNewMember(page);
    const code = await latestCode(request, member);
    await submitCode(page, code);
    await expect(page).not.toHaveURL(/show_verify/);

    // Someone else replaying the same code on the same account gets nowhere
    const stranger = await (await browser.newContext()).newPage();
    await stranger.goto(member.verifyUrl);
    await submitCode(stranger, code);
    await expect(stranger.locator('[href*="sign_out"]')).toHaveCount(0);
  });

  test('a new code can be requested at most once a minute', async ({ page }) => {
    await registerNewMember(page); // the first code was just sent
    await Promise.all([page.waitForNavigation(), page.getByRole('link', { name: 'Resend Code' }).click()]);
    await expect(page.getByText(/Please wait a minute before requesting another code/).first()).toBeVisible();
  });

  test('verified accounts cannot be logged into with a code', async ({ browser }) => {
    const stranger = await (await browser.newContext()).newPage();
    await stranger.goto('/');
    const token = await csrfToken(stranger);
    const response = await stranger.request.post(`/users/${seed().alice_user_slug}/verify`, {
      form: { authenticity_token: token, token: '123456' }, maxRedirects: 0
    });
    expect(response.status()).toBe(302);
    expect(response.headers().location).not.toMatch(/dashboard/);
  });
});
