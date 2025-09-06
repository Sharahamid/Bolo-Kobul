import consumer from "./consumer"

$(function () {
    var messages_to_bottom;

    if ($('#messageBody').length > 0) {
        messages_to_bottom = function () {
            return $('#messageBody').scrollTop($('#messageBody').prop("scrollHeight"));
        };

        setTimeout(function () {
            messages_to_bottom();
        }, 300);
    }
    consumer.subscriptions.create({
            channel: "RoomChannel",
            chat_room_id: $('#message_text').attr('data-chat-room-id')
        },
        {
            connected() {
                // Called when the subscription is ready for use on the server
                $('#message_text').attr('placeholder', 'Send message...');
                console.log('--you are connected wth room channel');
            },

            disconnected() {
                // Called when the subscription has been terminated by the server
                $('#message_text').attr('placeholder', 'Connecting...');
                console.log('--you are disconnected with room channel');
            },

            received(data) {
                // Called when there's incoming data on the websocket for this channel
                    var row_background =  data.content['sender_id'] == $('#privat-chat-messages').attr('data-login-user-id') ? 'conversation-row-text-right' : 'conversation-row-text-left';
                    var row_align =  data.content['sender_id'] == $('#privat-chat-messages').attr('data-login-user-id') ? 'align-self-end' : 'align-self-start';
                    $('#privat-chat-messages').append("<div class=\"d-flex flex-column pl-2 pr-2\">\n" +
                    "<div class=\""+ row_align +"\">" +
                    "  <span class=\" " + row_background  + "\"> " + data.content['body'] + "</span>\n" +
                    "  <small class=\"text-gray float-right\">" + $('#message_text').attr('date') + "</small>\n" +
                    "</div>" +
                    "</div>");
                $('#message_text').val('');
                return messages_to_bottom();
                console.log('--you have received data from room channel');
            }

        });

});
