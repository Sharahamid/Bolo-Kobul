// Bolo Kobul: offers phone/desktop notifications to signed-in members and keeps
// this device's subscription saved on the server.
(function () {
  var keyMeta = document.querySelector('meta[name="vapid-public-key"]');
  if (!keyMeta || !keyMeta.content) return;
  if (!('serviceWorker' in navigator) || !('PushManager' in window) || !('Notification' in window)) return;

  var DISMISS_KEY = 'bkPushPromptDismissedAt';
  var DISMISS_DAYS = 30;
  var prompt = document.getElementById('bk-push-prompt');

  function keyToBytes(base64url) {
    var padding = '='.repeat((4 - (base64url.length % 4)) % 4);
    var raw = atob((base64url + padding).replace(/-/g, '+').replace(/_/g, '/'));
    var bytes = new Uint8Array(raw.length);
    for (var i = 0; i < raw.length; i++) bytes[i] = raw.charCodeAt(i);
    return bytes;
  }

  function csrfToken() {
    var meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.content : '';
  }

  function saveSubscription(subscription) {
    return fetch('/push_subscriptions', {
      method: 'POST',
      credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken() },
      body: JSON.stringify(subscription.toJSON())
    });
  }

  function subscribe() {
    return navigator.serviceWorker.ready
      .then(function (registration) {
        return registration.pushManager.getSubscription().then(function (existing) {
          return existing || registration.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: keyToBytes(keyMeta.content)
          });
        });
      })
      .then(saveSubscription);
  }

  function dismissedRecently() {
    try {
      var at = parseInt(localStorage.getItem(DISMISS_KEY) || '0', 10);
      return Date.now() - at < DISMISS_DAYS * 24 * 60 * 60 * 1000;
    } catch (e) {
      return false;
    }
  }

  function hidePrompt() {
    if (prompt) prompt.hidden = true;
  }

  // Already allowed on this device: make sure the server has the subscription
  if (Notification.permission === 'granted') {
    subscribe().catch(function () {});
    return;
  }
  if (Notification.permission === 'denied' || !prompt || dismissedRecently()) return;

  prompt.hidden = false;

  function rememberAnswer() {
    try { localStorage.setItem(DISMISS_KEY, String(Date.now())); } catch (e) {}
  }

  prompt.querySelector('[data-push-enable]').addEventListener('click', function () {
    hidePrompt();
    // Some browsers close or silently ignore the permission request; don't ask again on every page
    rememberAnswer();
    Promise.resolve(Notification.requestPermission())
      .then(function (permission) {
        if (permission === 'granted') return subscribe();
      })
      .catch(function () {});
  });

  prompt.querySelector('[data-push-dismiss]').addEventListener('click', function () {
    hidePrompt();
    rememberAnswer();
  });
})();
