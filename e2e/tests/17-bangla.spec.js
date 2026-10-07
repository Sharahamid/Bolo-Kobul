const { test, expect } = require('@playwright/test');
const { login } = require('../support/helpers');

// English / বাংলা: the switch changes the language, and the choice is remembered
test.describe('Bangla version', () => {
  test('a visitor switches to Bangla and back; the choice stays on other pages', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('html')).toHaveAttribute('lang', 'en');
    await page.locator('footer, section').getByRole('link', { name: 'বাংলা' }).last().click();
    await expect(page.locator('html')).toHaveAttribute('lang', 'bn');
    await expect(page.getByText('খুঁজে নিন আপনার বিশেষ মানুষটিকে')).toBeVisible();

    await page.goto('/about');
    await expect(page.locator('html')).toHaveAttribute('lang', 'bn');
    await expect(page.getByRole('link', { name: 'আমাদের কথা' }).first()).toBeVisible();

    await page.getByRole('link', { name: 'English' }).last().click();
    await expect(page.locator('html')).toHaveAttribute('lang', 'en');
    await expect(page.getByRole('link', { name: 'About Us' }).first()).toBeVisible();
  });

  test("a member's language is saved on their account", async ({ browser }) => {
    const first = await (await browser.newContext()).newPage();
    await login(first, 'carol@example.com');
    await first.goto('/?locale=bn');
    await expect(first.locator('html')).toHaveAttribute('lang', 'bn');

    // A new device: Bangla again after logging in, without choosing it
    const second = await (await browser.newContext()).newPage();
    await login(second, 'carol@example.com');
    await expect(second.locator('html')).toHaveAttribute('lang', 'bn');
    await second.goto('/?locale=en');
  });
});
