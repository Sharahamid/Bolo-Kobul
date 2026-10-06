// Chime and vibration for a new message, like other messengers. Browsers only allow
// sound and vibration after the member has tapped or typed on the page; otherwise the
// phone notification (service worker) provides them.
export function chimeAndVibrate() {
    if (document.hidden) return;
    try {
        var chime = new Audio('/sounds/message.mp3');
        var playing = chime.play();
        if (playing && playing.catch) playing.catch(function () {});
    } catch (e) {}
    try {
        if (navigator.vibrate) navigator.vibrate([180, 80, 180]);
    } catch (e) {}
}

// Small banner at the bottom of the screen: "New message from BK… · Read"
export function showMessageBanner(from, url) {
    var old = document.getElementById('bk-message-banner');
    if (old) old.remove();
    var banner = document.createElement('a');
    banner.id = 'bk-message-banner';
    banner.href = url;
    banner.setAttribute('role', 'status');
    banner.style.cssText = 'position:fixed; left:50%; bottom:calc(20px + var(--bk-bottom-nav-h, 0px)); transform:translateX(-50%); z-index:2000;' +
        'display:flex; align-items:center; gap:10px; max-width:calc(100% - 32px); box-sizing:border-box;' +
        'background:#412402; color:#FFFFFF; padding:12px 18px; border-radius:999px; text-decoration:none;' +
        'box-shadow:0 6px 20px rgba(0,0,0,0.25); font-size:14px; line-height:1.3;';
    var text = document.createElement('span');
    text.textContent = '💬 New message from ' + from;
    var action = document.createElement('strong');
    action.textContent = 'Read';
    action.style.cssText = 'color:#FFB627; white-space:nowrap;';
    banner.appendChild(text);
    banner.appendChild(action);
    document.body.appendChild(banner);
    setTimeout(function () { if (banner.parentNode) banner.remove(); }, 10000);
}
