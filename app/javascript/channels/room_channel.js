import consumer from "./consumer"
import { chimeAndVibrate } from "./bk_alert"

// Live chat: messages appear for both people without refreshing.

// Tell the server a message arriving in the open chat has been seen
function markRead(chatRoomId) {
    var token = document.querySelector('meta[name="csrf-token"]');
    fetch('/messages/read', {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': token ? token.content : '' },
        body: JSON.stringify({ chat_room_id: chatRoomId })
    }).catch(function () {});
}

// WhatsApp-style ticks, same as message_ticks in application_helper.rb:
// one grey = sent, two grey = delivered, two blue = read
var TICK_LABELS = { sent: 'Sent', delivered: 'Delivered', read: 'Read' };
function ticks(createdAt, status) {
    var path = status === 'sent' ? 'M4 8.5l3 3 6-7' : 'M1 8.5l3 3 6-7M7.5 11.5l6-7';
    var color = status === 'read' ? '#34B7F1' : '#9aa0a6';
    return '<span class="bk-ticks" title="' + TICK_LABELS[status] + '" aria-label="' + TICK_LABELS[status] + '"' +
        ' data-created="' + createdAt + '" data-status="' + status + '"' +
        ' style="display:inline-flex; vertical-align:middle; margin-left:4px;">' +
        '<svg width="16" height="12" viewBox="0 0 16 14" aria-hidden="true"><path d="' + path + '" fill="none" stroke="' + color + '"' +
        ' stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"></path></svg></span>';
}

// The other person received or read the chat: upgrade the ticks on my messages
var RANK = { sent: 0, delivered: 1, read: 2 };
function applyReceipt(receipt) {
    var readAt = receipt.read_at ? Date.parse(receipt.read_at) : null;
    var deliveredAt = receipt.delivered_at ? Date.parse(receipt.delivered_at) : null;
    document.querySelectorAll('#privat-chat-messages .bk-ticks').forEach(function (el) {
        var created = Date.parse(el.getAttribute('data-created'));
        var status = readAt && created <= readAt ? 'read' : (deliveredAt && created <= deliveredAt ? 'delivered' : 'sent');
        if (RANK[status] > RANK[el.getAttribute('data-status')]) el.outerHTML = ticks(el.getAttribute('data-created'), status);
    });
}

// Same look as app/views/messages/_conversation_row.html.erb. The body and the quoted
// text arrive already HTML-escaped from the server.
function escapeAttr(text) {
    return String(text || '').replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
function quoteText(escapedBody) {
    var div = document.createElement('div');
    div.innerHTML = escapedBody || '';
    var text = (div.textContent || '').replace(/\s+/g, ' ').trim();
    return text.length > 120 ? text.slice(0, 119) + '…' : text;
}
function senderLabel(senderId) {
    var list = document.getElementById('privat-chat-messages');
    if (!list) return '';
    return String(senderId) === String(list.getAttribute('data-login-user-id'))
        ? list.getAttribute('data-you-label') : list.getAttribute('data-other-label');
}
function messageRow(content, mine) {
    var time = window.bkLocalTime ? window.bkLocalTime(content['created_at']) : '';
    var reply = content['reply'];
    var list = document.getElementById('privat-chat-messages');
    var replyLabel = list ? list.getAttribute('data-reply-label') : 'Reply';
    var quote = reply
        ? '<a href="#bk-msg-' + reply.id + '" class="bk-msg__quote" data-quote-jump="' + reply.id + '">' +
          '<span class="bk-msg__quote-who">' + escapeAttr(senderLabel(reply.sender_id)) + '</span>' +
          '<span class="bk-msg__quote-text">' + reply.text + '</span></a>'
        : '';
    return '<div class="d-flex flex-column"><div class="conversation-row">' +
        '<div class="bk-msg ' + (mine ? 'bk-msg--mine' : 'bk-msg--theirs') + '" id="bk-msg-' + content['id'] + '"' +
        ' data-message-id="' + content['id'] + '" data-sender-id="' + content['sender_id'] + '"' +
        ' data-quote="' + escapeAttr(quoteText(content['body'])) + '">' +
        '<div class="bk-msg__wrap"><div class="bk-msg__bubble">' + quote +
        '<div class="bk-msg__text">' + content['body'] + '</div></div>' +
        '<div class="bk-msg__meta"><time class="js-local-time" data-format="message" datetime="' + (content['created_at'] || '') + '">' + time + '</time>' +
        (mine ? ticks(content['created_at'] || '', 'sent') : '') + '</div></div>' +
        '<button type="button" class="bk-msg__reply" title="' + escapeAttr(replyLabel) + '" aria-label="' + escapeAttr(replyLabel) + '">↩</button>' +
        '</div></div></div>';
}

// ---- Reply to one message, like WhatsApp ----
// Swipe a message to the right on a phone, or press ↩ beside it on a computer. A bar
// above the typing box shows what is being answered; ✕ cancels it.
function startReply(row) {
    var bar = document.getElementById('bk-reply-bar');
    var field = document.getElementById('message_reply_to_id');
    if (!bar || !field || !row) return;
    field.value = row.getAttribute('data-message-id');
    document.getElementById('bk-reply-who').textContent = senderLabel(row.getAttribute('data-sender-id'));
    document.getElementById('bk-reply-text').textContent = row.getAttribute('data-quote') || '';
    bar.hidden = false;
    var box = document.getElementById('message_text');
    if (box) box.focus();
}
function cancelReply() {
    var bar = document.getElementById('bk-reply-bar');
    var field = document.getElementById('message_reply_to_id');
    if (field) field.value = '';
    if (bar) bar.hidden = true;
}
function setUpReplies() {
    var list = document.getElementById('privat-chat-messages');
    if (!list || list.getAttribute('data-replies-ready')) return;
    list.setAttribute('data-replies-ready', '1');

    var cancel = document.getElementById('bk-reply-cancel');
    if (cancel) cancel.addEventListener('click', cancelReply);

    list.addEventListener('click', function (event) {
        var button = event.target.closest('.bk-msg__reply');
        if (button) { startReply(button.closest('.bk-msg')); return; }
        // Tapping a quote jumps to the message it answers and makes it glow briefly
        var quote = event.target.closest('[data-quote-jump]');
        if (quote) {
            event.preventDefault();
            var target = document.getElementById('bk-msg-' + quote.getAttribute('data-quote-jump'));
            if (target) {
                target.scrollIntoView({ behavior: 'smooth', block: 'center' });
                target.classList.add('bk-msg--flash');
                setTimeout(function () { target.classList.remove('bk-msg--flash'); }, 1400);
            }
        }
    });

    // Phone: swipe a message right by about 60px to reply (the bubble follows the finger)
    var startX = 0, startY = 0, row = null, wrap = null, moved = 0;
    list.addEventListener('touchstart', function (event) {
        row = event.target.closest('.bk-msg');
        // Also when the finger starts on the quote of a reply (a swipe is not a tap on it)
        if (!row) return;
        wrap = row.querySelector('.bk-msg__wrap');
        startX = event.touches[0].clientX;
        startY = event.touches[0].clientY;
        moved = 0;
    }, { passive: true });
    list.addEventListener('touchmove', function (event) {
        if (!row) return;
        var dx = event.touches[0].clientX - startX;
        var dy = event.touches[0].clientY - startY;
        if (Math.abs(dy) > Math.abs(dx)) { if (Math.abs(dy) > 10) { wrap.style.transform = ''; row = null; } return; }
        moved = Math.max(0, Math.min(dx, 80));
        wrap.style.transform = 'translateX(' + moved + 'px)';
    }, { passive: true });
    list.addEventListener('touchend', function () {
        if (!row) return;
        wrap.style.transform = '';
        if (moved >= 60) startReply(row);
        row = null;
    });
}

// The message box grows with the text (up to about 5 lines), like WhatsApp. On a
// computer Enter sends and Shift+Enter starts a new line; on a phone Enter is a new
// line and the send button sends.
function setUpMessageBox(box) {
    var form = box.form;
    var sendButton = form.querySelector('[type="submit"]');
    var computer = window.matchMedia && window.matchMedia('(pointer: fine)').matches;

    function resize() {
        box.style.height = 'auto';
        box.style.height = Math.min(box.scrollHeight, 120) + 'px';
    }
    box.addEventListener('input', resize);
    box.addEventListener('keydown', function (event) {
        if (event.key !== 'Enter' || event.shiftKey || !computer || event.isComposing) return;
        event.preventDefault();
        if (box.value.trim() !== '') sendButton.click();
    });
    form.addEventListener('submit', function (event) {
        if (box.value.trim() === '') {
            event.preventDefault();
            event.stopImmediatePropagation();
        }
    }, true);
    box.bkResize = resize;
}

// ---- Catch up on missed messages ----
// Phones put the live connection to sleep when the screen is off, and some networks block
// it. So the open chat also asks the server for anything newer than the last message on
// screen: when the connection comes back, when the page is shown again, and every 15
// seconds while the chat is open. Messages already shown are never added twice.
function lastMessageId() {
    var max = 0;
    document.querySelectorAll('#privat-chat-messages .bk-msg[data-message-id]').forEach(function (el) {
        var id = parseInt(el.getAttribute('data-message-id'), 10);
        if (id > max) max = id;
    });
    return max;
}
var catchingUp = false, catchUpAgain = false;
function catchUp(chatRoomId, onNew) {
    if (!chatRoomId) return;
    if (catchingUp) { catchUpAgain = true; return; }
    catchingUp = true;
    fetch('/messages/since?chat_room_id=' + encodeURIComponent(chatRoomId) + '&after_id=' + lastMessageId(),
          { credentials: 'same-origin', headers: { 'Accept': 'application/json' } })
        .then(function (r) { return r.ok ? r.json() : []; })
        .then(function (list) { (list || []).forEach(function (content) { onNew(content, true); }); })
        .catch(function () {})
        .finally(function () {
            catchingUp = false;
            if (catchUpAgain) { catchUpAgain = false; catchUp(chatRoomId, onNew); }
        });
}

$(function () {
    var box = document.getElementById('message_text');
    if (!box) return;
    setUpMessageBox(box);
    setUpReplies();

    var messages_to_bottom = function () {
        return $('#messageBody').scrollTop($('#messageBody').prop("scrollHeight"));
    };
    setTimeout(messages_to_bottom, 300);

    var chatRoomId = box.getAttribute('data-chat-room-id');

    // Shows one message (live or caught up), once only
    function addMessage(content, fromCatchUp) {
        if (!content || document.getElementById('bk-msg-' + content['id'])) return;
        var myProfileId = String($('#privat-chat-messages').attr('data-login-user-id'));
        var mine = String(content['sender_id']) === myProfileId;
        $('#privat-chat-messages').append(messageRow(content, mine));
        if (mine) {
            // First message sent: the conversation starters are no longer needed
            var starters = document.getElementById('bk-icebreakers');
            if (starters) starters.remove();
        } else {
            chimeAndVibrate();
            if (!fromCatchUp) markRead(content['chat_room_id']);
        }
        messages_to_bottom();
    }

    // Sent: empty the box straight away and show the message, even if the live
    // connection is not working
    if (box.form) {
        box.form.addEventListener('ajax:success', function () {
            box.value = '';
            box.bkResize();
            cancelReply();
            catchUp(chatRoomId, addMessage);
        });
    }

    document.addEventListener('visibilitychange', function () {
        if (!document.hidden) catchUp(chatRoomId, addMessage);
    });
    setInterval(function () { if (!document.hidden) catchUp(chatRoomId, addMessage); }, 15000);

    consumer.subscriptions.create({
            channel: "RoomChannel",
            chat_room_id: chatRoomId
        },
        {
            connected() {
                box.setAttribute('placeholder', box.getAttribute('data-placeholder-connected') || 'Send message...');
                // Back online (or first connect): fetch anything sent meanwhile
                catchUp(chatRoomId, addMessage);
            },

            disconnected() {
                box.setAttribute('placeholder', box.getAttribute('data-placeholder-connecting') || 'Connecting...');
            },

            received(data) {
                var myProfileId = String($('#privat-chat-messages').attr('data-login-user-id'));
                if (data.receipt) {
                    if (String(data.receipt.profile_id) !== myProfileId) applyReceipt(data.receipt);
                    return;
                }
                addMessage(data.content, false);
            }
        });
});
