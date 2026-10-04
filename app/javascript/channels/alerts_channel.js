import consumer from "./consumer"
import { chimeAndVibrate, showMessageBanner } from "./bk_alert"

// New-message alerts on every page. The open chat for that conversation shows the
// message itself (room_channel.js), so it is skipped here.
consumer.subscriptions.create({ channel: "AlertsChannel" }, {
    received(data) {
        if (data.kind !== 'message') return;
        // Two grey ticks for the sender: the message reached this phone or browser
        this.perform('delivered');
        var openChat = document.getElementById('message_text');
        if (openChat && String(openChat.getAttribute('data-chat-room-id')) === String(data.chat_room_id)) return;
        chimeAndVibrate();
        showMessageBanner(data.from, data.url);
    }
});
