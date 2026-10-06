const { test, expect } = require('@playwright/test');
const { login, seed } = require('../support/helpers');

// App-style bar on phones: Home, Matches, Kobuls, Chats, Profile
test.describe('Phone bottom bar', () => {
  test('shows on phones, links to the right places, and stays out of conversations and computers', async ({ browser }) => {
    const { members } = seed();
    const phone = await (await browser.newContext({ viewport: { width: 390, height: 844 }, isMobile: true, hasTouch: true })).newPage();
    await login(phone, 'alice@example.com');
    await phone.goto(`/marriage_profiles/${members.alice}/dashboard`);
    const bar = phone.locator('.bk-bottom-nav');
    await expect(bar).toBeVisible();
    for (const name of ['Home', 'Matches', 'Kobuls', 'Chats', 'Profile']) await expect(bar.getByRole('link', { name })).toBeVisible();
    await expect(bar.getByRole('link', { name: 'Home' })).toHaveClass(/active/);

    await bar.getByRole('link', { name: 'Kobuls' }).click();
    await expect(phone).toHaveURL(/#bk-kobul-requests$/);
    await expect(bar.getByRole('link', { name: 'Kobuls' })).toHaveClass(/active/);

    await bar.getByRole('link', { name: 'Profile' }).click();
    await expect(phone).toHaveURL(new RegExp(`/marriage_profiles/${members.alice}/profile_info`));
    await expect(bar.getByRole('link', { name: 'Profile' })).toHaveClass(/active/);

    // Alice and Bob can chat: no bar inside the conversation, so it never covers the message box
    await phone.goto(`/messages/${members.bob}/profile`);
    await expect(phone.locator('.bk-bottom-nav')).toHaveCount(0);

    const computer = await (await browser.newContext({ viewport: { width: 1366, height: 900 } })).newPage();
    await computer.context().addCookies(await phone.context().cookies());
    await computer.goto(`/marriage_profiles/${members.alice}/dashboard`);
    await expect(computer.locator('.bk-bottom-nav')).toBeHidden();
  });
});
