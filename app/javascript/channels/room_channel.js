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

// Same look as app/views/messages/_conversation_row.html.erb. The body arrives
// already HTML-escaped from the server.
function messageRow(content, mine) {
    var time = window.bkLocalTime ? window.bkLocalTime(content['created_at']) : '';
    return '<div class="d-flex flex-column"><div class="conversation-row">' +
        '<div style="display:flex; justify-content:' + (mine ? 'flex-end' : 'flex-start') + '; margin-bottom:8px;"><div>' +
        '<div style="background:' + (mine ? '#FFB627' : '#f0f0f0') + '; color:' + (mine ? '#412402' : '#444') + '; padding:8px 14px;' +
        ' border-radius:' + (mine ? '14px 4px 14px 14px' : '4px 14px 14px 14px') + '; font-size:13px; max-width:260px;' +
        ' word-wrap:break-word; overflow-wrap:anywhere; white-space:pre-wrap; line-height:1.5;">' + content['body'] + '</div>' +
        '<div style="font-size:10px; color:#aaa; margin-top:3px; text-align:' + (mine ? 'right' : 'left') + ';">' +
        '<time class="js-local-time" data-format="message" datetime="' + (content['created_at'] || '') + '">' + time + '</time>' +
        (mine ? ticks(content['created_at'] || '', 'sent') : '') + '</div>' +
        '</div></div></div></div>';
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

$(function () {
    var box = document.getElementById('message_text');
    if (!box) return;
    setUpMessageBox(box);

    var messages_to_bottom = function () {
        return $('#messageBody').scrollTop($('#messageBody').prop("scrollHeight"));
    };
    setTimeout(messages_to_bottom, 300);

    consumer.subscriptions.create({
            channel: "RoomChannel",
            chat_room_id: box.getAttribute('data-chat-room-id')
        },
        {
            connected() {
                box.setAttribute('placeholder', 'Send message...');
            },

            disconnected() {
                box.setAttribute('placeholder', 'Connecting...');
            },

            received(data) {
                var myProfileId = String($('#privat-chat-messages').attr('data-login-user-id'));
                if (data.receipt) {
                    if (String(data.receipt.profile_id) !== myProfileId) applyReceipt(data.receipt);
                    return;
                }
                var mine = String(data.content['sender_id']) === myProfileId;
                $('#privat-chat-messages').append(messageRow(data.content, mine));
                if (mine) {
                    box.value = '';
                    box.bkResize();
                } else {
                    chimeAndVibrate();
                    markRead(data.content['chat_room_id']);
                }
                return messages_to_bottom();
            }
        });
});
