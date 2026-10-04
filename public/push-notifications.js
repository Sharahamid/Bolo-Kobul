// Bolo Kobul: offers phone/desktop notifications to signed-in members and keeps
// this device's subscription saved on the server.
(function () {
  var keyMeta = document.querySelector('meta[name="vapid-public-key"]');
  if (!keyMeta || !keyMeta.content) return;
  if (!('serviceWorker' in navigator) || !('PushManager' in window) || !('Notification' in window)) return;

  // Until notifications are on, the prompt shows once a day: on the first page of the day
  var SHOWN_DAY_KEY = 'bkPushPromptShownDay';
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

  function today() {
    var d = new Date();
    return d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate();
  }

  // True the first time this is called on a given day (per device)
  function firstVisitToday() {
    try {
      if (localStorage.getItem(SHOWN_DAY_KEY) === today()) return false;
      localStorage.setItem(SHOWN_DAY_KEY, today());
      return true;
    } catch (e) {
      return true;
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
  if (Notification.permission === 'denied' || !prompt || !firstVisitToday()) return;

  prompt.hidden = false;

  prompt.querySelector('[data-push-enable]').addEventListener('click', function () {
    hidePrompt();
    Promise.resolve(Notification.requestPermission())
      .then(function (permission) {
        if (permission === 'granted') return subscribe();
      })
      .catch(function () {});
  });

  prompt.querySelector('[data-push-dismiss]').addEventListener('click', hidePrompt);
})();
