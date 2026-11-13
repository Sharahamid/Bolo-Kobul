import consumer from "./consumer"
import { chimeAndVibrate, showMessageBanner } from "./bk_alert"

// Phones keep a copy of the last page and show it again on "Back" without asking the
// server, so old counts (the red number on Chats, "New message") would stay. Reload it.
window.addEventListener('pageshow', function (event) {
    if (event.persisted) window.location.reload();
});

// The red number on Chats in the bottom bar: one per chat with something unread
function bumpChatBadge(chatRoomId) {
    var badge = document.getElementById('bk-chat-badge');
    if (!badge) return;
    var rooms = (badge.getAttribute('data-rooms') || '').split(',').filter(Boolean);
    if (rooms.indexOf(String(chatRoomId)) === -1) rooms.push(String(chatRoomId));
    badge.setAttribute('data-rooms', rooms.join(','));
    badge.textContent = rooms.length > 9 ? '9+' : rooms.length;
    badge.hidden = rooms.length === 0;
}

// New-message alerts on every page. The open chat for that conversation shows the
// message itself (room_channel.js), so it is skipped here.
consumer.subscriptions.create({ channel: "AlertsChannel" }, {
    received(data) {
        if (data.kind !== 'message') return;
        // Two grey ticks for the sender: the message reached this phone or browser
        this.perform('delivered');
        var openChat = document.getElementById('message_text');
        if (openChat && String(openChat.getAttribute('data-chat-room-id')) === String(data.chat_room_id)) return;
        bumpChatBadge(data.chat_room_id);
        chimeAndVibrate();
        showMessageBanner(data.from, data.url);
    }
});
