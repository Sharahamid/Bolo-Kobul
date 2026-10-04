const { test, expect } = require('@playwright/test');
const { login, seed, csrfToken } = require('../support/helpers');

test.describe('Chat', () => {
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
