// Shows chat times in the viewer's own time zone. The server marks each time as
// <time class="js-local-time" datetime="(UTC)" data-format="message|day">.
(function () {
  // Bangla pages show Bangla months and digits
  function lang() { return document.documentElement.lang === 'bn' ? 'bn-BD' : 'en-US'; }

  function format(iso, kind) {
    var date = new Date(iso);
    if (isNaN(date)) return null;
    if (kind === 'day') return date.toLocaleDateString(lang(), { month: 'short', day: '2-digit' });
    return date.toLocaleDateString(lang(), { month: 'short', day: 'numeric' }) + ', ' +
           date.toLocaleTimeString(lang(), { hour: 'numeric', minute: '2-digit' });
  }

  function localize(root) {
    (root || document).querySelectorAll('time.js-local-time').forEach(function (el) {
      var text = format(el.getAttribute('datetime'), el.getAttribute('data-format'));
      if (text) el.textContent = text;
    });
  }

  // Used by the live chat for messages that arrive while the page is open
  window.bkLocalTime = function (iso) { return format(iso || new Date().toISOString(), 'message') || ''; };
  window.bkLocalizeTimes = localize;

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', function () { localize(); });
  else localize();
  document.addEventListener('turbolinks:load', function () { localize(); });
})();
