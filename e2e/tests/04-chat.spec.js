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
