const { test, expect } = require('@playwright/test');
const { login, seed, csrfToken } = require('../support/helpers');

test.describe('Chat', () => {
  // Close every page a test opened: an open chat page keeps receiving (and reading) messages
  test.afterEach(async ({ browser }) => {
    await Promise.all(browser.contexts().map((context) => context.close()));
  });

  test('a message appears for the other member live, without refreshing', async ({ browser }) => {
    const alice = await (await browser.newContext()).newPage();
    const bob = await (await browser.newContext()).newPage();
    await login(alice, 'alice@example.com');
    await login(bob, 'bob@example.com');

    await bob.goto(`/messages/${seed().members.alice}/profile`);
    await alice.goto(`/messages/${seed().members.bob}/profile`);
    // Both chat windows show "Send message..." once their live connection is ready
    await expect(bob.locator('#message_text')).toHaveAttribute('placeholder', 'Send message...');
    await expect(alice.locator('#message_text')).toHaveAttribute('placeholder', 'Send message...');

    const text = `Hello from Alice ${Date.now()}`;
    await alice.locator('#message_text').fill(text);
    await alice.locator('#message_text').press('Enter');

    await expect(bob.getByText(text)).toBeVisible({ timeout: 15_000 });
  });

  test('on a phone the message box is visible and sending works', async ({ browser }) => {
    const alice = await (await browser.newContext()).newPage();
    await login(alice, 'alice@example.com');
    const phone = await (await browser.newContext({ viewport: { width: 390, height: 844 }, isMobile: true, hasTouch: true })).newPage();
    await phone.context().addCookies(await alice.context().cookies());
    await phone.goto(`/messages/${seed().members.bob}/profile`);

    const box = phone.locator('#message_text');
    await expect(box).toHaveAttribute('placeholder', 'Send message...');
    // Nothing on the way up the page may cut the send button off (a person can't
    // scroll inside a box whose overflow is hidden, even if a test tool can)
    const clipped = await phone.locator('.msg-send-btn').evaluate((button) => {
      const b = button.getBoundingClientRect();
      for (let el = button.parentElement; el && el !== document.body; el = el.parentElement) {
        const style = getComputedStyle(el);
        if (!/(hidden|clip|auto|scroll)/.test(style.overflowY)) continue;
        const r = el.getBoundingClientRect();
        if (b.bottom > r.bottom + 1 || b.top < r.top - 1) return el.className || el.tagName;
      }
      return null;
    });
    expect(clipped).toBeNull();
    await box.scrollIntoViewIfNeeded();
    await expect(box).toBeVisible();
    // Not cut off by the chat area: the send button can actually be tapped
    const text = `From a phone ${Date.now()}`;
    await box.fill(text);
    await phone.locator('.msg-send-btn').tap();
    await expect(phone.locator('#messageBody').getByText(text)).toBeVisible({ timeout: 15_000 });
  });

  test("message times are shown in the viewer's own time zone", async ({ browser }) => {
    for (const timezoneId of ['Asia/Dhaka', 'America/New_York']) {
      const page = await (await browser.newContext({ timezoneId })).newPage();
      await login(page, 'alice@example.com');
      await page.goto(`/messages/${seed().members.bob}/profile`);
      await expect(page.locator('#message_text')).toHaveAttribute('placeholder', 'Send message...');
      const text = `Time check ${timezoneId} ${Date.now()}`;
      await page.locator('#message_text').fill(text);
      await page.locator('#message_text').press('Enter');
      await expect(page.locator('#privat-chat-messages').getByText(text)).toBeVisible();

      // The clock time of "now" in this browser's zone, e.g. "11:17 PM"
      const clock = await page.evaluate(() => new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }));
      const hour = clock.split(':')[0];
      await page.reload();
      const shown = await page.locator('#messageBody time.js-local-time').last().textContent();
      expect(shown).toContain(`, ${hour}:`);
    }
  });

  test('a new message chimes in the open chat and shows as "New message" on the chat card until read', async ({ browser }) => {
    const alice = await (await browser.newContext()).newPage();
    const bob = await (await browser.newContext()).newPage();
    await login(alice, 'alice@example.com');
    await login(bob, 'bob@example.com');

    // Alice is away from the chat: Bob's message shows as new on her chat card
    await bob.goto(`/messages/${seed().members.alice}/profile`);
    await expect(bob.locator('#message_text')).toHaveAttribute('placeholder', 'Send message...');
    await bob.locator('#message_text').fill(`Are you there? ${Date.now()}`);
    await bob.locator('#message_text').press('Enter');
    await expect(bob.locator('#message_text')).toHaveValue('');
    await alice.goto('/messages');
    const card = alice.locator('.bk-chat-card').first();
    await expect(card.locator('.bk-new-message')).toBeVisible();

    // Tapping anywhere on the card (not just the name) opens the chat, which marks it read
    await Promise.all([alice.waitForURL(/\/messages\/.+\/profile/), card.locator('span', { hasText: 'years' }).click()]);
    await expect(alice.locator('.bk-chat-card .bk-new-message')).toHaveCount(0);

    // With the chat open, a new message plays the chime
    await alice.evaluate(() => {
      window.bkChimes = 0;
      const play = HTMLMediaElement.prototype.play;
      HTMLMediaElement.prototype.play = function () { window.bkChimes += 1; return Promise.resolve(); };
    });
    await expect(alice.locator('#message_text')).toHaveAttribute('placeholder', 'Send message...');
    const text = `Ding ${Date.now()}`;
    await bob.locator('#message_text').fill(text);
    await bob.locator('#message_text').press('Enter');
    await expect(alice.getByText(text)).toBeVisible({ timeout: 15_000 });
    await expect.poll(() => alice.evaluate(() => window.bkChimes)).toBe(1);

    // Seen live, so it is not "new" when she comes back to her chat list
    await alice.waitForTimeout(500);
    await alice.goto('/messages');
    await expect(alice.locator('.bk-chat-card .bk-new-message')).toHaveCount(0);
  });

  test('chatting only opens after both 2nd Kobuls are accepted', async ({ browser }) => {
    const carol = await (await browser.newContext()).newPage();
    await login(carol, 'carol@example.com');
    await carol.goto(`/messages/${seed().members.alice}/profile`);
    await expect(carol).toHaveURL(new RegExp(`/marriage_profiles/${seed().members.alice}/profile_info`));
    await expect(carol.locator('#message_text')).toHaveCount(0);
  });

  test("someone outside the chat cannot post into it", async ({ browser }) => {
    const alice = await (await browser.newContext()).newPage();
    await login(alice, 'alice@example.com');
    await alice.goto(`/messages/${seed().members.bob}/profile`);
    const roomId = await alice.locator('[name="message[chat_room_id]"]').inputValue();

    const carol = await (await browser.newContext()).newPage();
    await login(carol, 'carol@example.com');
    const response = await carol.request.post('/messages', {
      headers: { 'X-CSRF-Token': await csrfToken(carol), Accept: 'text/javascript' },
      form: { 'message[body]': 'intruder', 'message[chat_room_id]': roomId }
    });
    expect(response.status()).toBe(403);
  });

  test('code inside a chat message is shown as text and never runs', async ({ browser }) => {
    const alice = await (await browser.newContext()).newPage();
    const bob = await (await browser.newContext()).newPage();
    await login(alice, 'alice@example.com');
    await login(bob, 'bob@example.com');
    await bob.goto(`/messages/${seed().members.alice}/profile`);
    await alice.goto(`/messages/${seed().members.bob}/profile`);
    await expect(bob.locator('#message_text')).toHaveAttribute('placeholder', 'Send message...');
    await expect(alice.locator('#message_text')).toHaveAttribute('placeholder', 'Send message...');

    const attack = `<img src=x onerror="window.__hacked=1"> hi ${Date.now()}`;
    await alice.locator('#message_text').fill(attack);
    await alice.locator('#message_text').press('Enter');

    await expect(bob.getByText(attack)).toBeVisible({ timeout: 15_000 });
    expect(await bob.evaluate(() => window.__hacked)).toBeUndefined();
    expect(await bob.locator('#privat-chat-messages img[src="x"]').count()).toBe(0);
  });
});
