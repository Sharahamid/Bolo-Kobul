const { test, expect } = require('@playwright/test');
const { login, seed } = require('../support/helpers');

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
    // The switch is in the menu after login too, and keeps the same page
    const page = new URL(first.url()).pathname;
    await first.locator('.navbar .bk-lang-switch').getByText('বাংলা').click();
    await expect(first.locator('html')).toHaveAttribute('lang', 'bn');
    expect(new URL(first.url()).pathname).toBe(page);

    // A new device: Bangla again after logging in, without choosing it
    const second = await (await browser.newContext()).newPage();
    await login(second, 'carol@example.com');
    await expect(second.locator('html')).toHaveAttribute('lang', 'bn');
    await second.goto('/?locale=en');
  });

  test('in Bangla, search, forms and messages are in Bangla but save the same values', async ({ page }) => {
    const { members } = seed();
    await login(page, 'carol@example.com');

    // Search: Bangla labels and options; the search sends the usual English values
    await page.goto(`/marriage_profiles/${members.carol}/search_page?locale=bn`);
    await expect(page.getByText('আমি খুঁজছি...')).toBeVisible();
    await page.locator('#bk-search-form select[name="religion"]').selectOption({ label: 'ইসলাম' });
    await page.locator('#bk-search-form select[name="hometown"]').selectOption({ label: 'ঢাকা' });
    await Promise.all([page.waitForNavigation(), page.getByRole('button', { name: '🔍 খুঁজুন' }).click()]);
    expect(new URL(page.url()).searchParams.get('religion')).toBe('Islam');
    expect(new URL(page.url()).searchParams.get('hometown')).toBe('Dhaka');

    // The basic information form opens in Bangla with the saved answers still selected
    await page.goto(`/marriage_profiles/${members.carol}/profile_info`);
    const form = await page.evaluate(async (url) => (await fetch(url, { headers: { Accept: 'text/javascript', 'X-Requested-With': 'XMLHttpRequest' } })).text(),
      `/marriage_profiles/${members.carol}/edit`);
    expect(form).toContain('মৌলিক তথ্য');
    expect(form).toMatch(/selected=\\?"selected\\?" value=\\?"Dhaka\\?">ঢাকা</);
    expect(form).not.toContain('translation missing');

    // On-screen messages are shown in Bangla (chat is not open with Alice yet)
    await page.goto(`/messages/${members.alice}/profile`);
    await expect(page.getByText('পছন্দের প্রোফাইলে ২টি কবুল পাঠানোর পর তারা গ্রহণ করলেই চ্যাট চালু হবে')).toBeVisible();

    await page.goto('/?locale=en');
    await expect(page.locator('html')).toHaveAttribute('lang', 'en');
  });
});

test.describe('Bangla content written by the admin', () => {
  test('a Bangla FAQ title shows on the Bangla site; the English site keeps the English one', async ({ page }) => {
    const stamp = Date.now();
    await page.goto('/shefali007/login');
    await page.locator('#admin_user_email').fill(seed().admin);
    await page.locator('#admin_user_password').fill(seed().password);
    await Promise.all([page.waitForNavigation(), page.locator('input[type="submit"]').click()]);

    await page.goto('/shefali007/faqs/new');
    await page.locator('#faq_title').fill(`How do Kobuls work? ${stamp}`);
    await page.locator('#faq_title_bn').fill(`কবুল কীভাবে কাজ করে? ${stamp}`);
    await page.locator('#faq_display_order').fill('999');
    await Promise.all([page.waitForNavigation(), page.locator('input[type="submit"]').click()]);
    await expect(page.locator('.attributes_table')).toContainText(`কবুল কীভাবে কাজ করে? ${stamp}`);

    await page.context().clearCookies();
    await page.goto('/faqs?locale=bn');
    await expect(page.getByText(`কবুল কীভাবে কাজ করে? ${stamp}`).first()).toBeAttached();
    await expect(page.getByText(`How do Kobuls work? ${stamp}`)).toHaveCount(0);
    await page.goto('/faqs?locale=en');
    await expect(page.getByText(`How do Kobuls work? ${stamp}`).first()).toBeAttached();
    await expect(page.getByText(`কবুল কীভাবে কাজ করে? ${stamp}`)).toHaveCount(0);
  });
});
