const { test, expect } = require('@playwright/test');
const { login, seed } = require('../support/helpers');
const { execSync } = require('child_process');

// Runs a helper script the same way the test members are seeded
function unsubscribeToken(email) {
  const seedCommand = process.env.E2E_SEED_COMMAND || 'bundle exec rails runner e2e/support/seed.rb';
  const output = execSync(seedCommand.replace('e2e/support/seed.rb', `e2e/support/unsubscribe_token.rb ${email}`),
                          { cwd: require('path').join(__dirname, '..', '..'), encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] });
  return output.trim().split('\n').pop();
}

test.describe('Photo protection', () => {
  test("other members' photos carry the viewer's watermark and can't be saved by right-click or long-press", async ({ page }) => {
    const { members } = seed();
    await login(page, 'alice@example.com');
    await page.goto(`/marriage_profiles/${members.bob}/profile_info`);
    expect(await page.locator('.bk-wm').count()).toBeGreaterThan(0);
    const watermark = await page.evaluate(() => getComputedStyle(document.documentElement).getPropertyValue('--bk-wm'));
    expect(decodeURIComponent(watermark)).toContain('Bolo Kobul');
    const blocked = await page.evaluate(() => {
      const target = document.querySelector('.bk-wm');
      const event = new MouseEvent('contextmenu', { bubbles: true, cancelable: true });
      target.dispatchEvent(event);
      return event.defaultPrevented;
    });
    expect(blocked).toBe(true);
  });
});

test.describe('Matches email', () => {
  test('the unsubscribe link turns the email off without logging in, and it can be turned back on', async ({ page }) => {
    const token = unsubscribeToken('carol@example.com');
    await page.goto(`/weekly-email/unsubscribe?token=${encodeURIComponent(token)}`);
    await expect(page.getByText("You're unsubscribed")).toBeVisible();
    await page.getByRole('button', { name: 'Send me matches again' }).click();
    await expect(page.getByText("You're subscribed again")).toBeVisible();

    await page.goto('/weekly-email/unsubscribe?token=forged');
    await expect(page.getByText('This link has expired')).toBeVisible();
  });
});
