// = require active_admin/base

// Search box in the admin top bar (next to the signed-in email). While typing it suggests
// matches from every admin page (AdminSearch); Enter opens the full results page.
(function () {
  var BASE = '/shaheer10inara20/search';

  function esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function setup() {
    var nav = document.getElementById('utility_nav');
    if (!nav || document.getElementById('bk-admin-search')) return;

    var li = document.createElement('li');
    li.id = 'bk-admin-search';
    li.innerHTML =
      '<form action="' + BASE + '" method="get" autocomplete="off">' +
      '<input type="search" name="q" placeholder="Search everything…" aria-label="Search the admin">' +
      '<div class="bk-search-drop" hidden></div></form>';
    nav.insertBefore(li, nav.firstChild);

    var input = li.querySelector('input');
    var drop = li.querySelector('.bk-search-drop');
    var timer = null, last = '', active = -1;

    function close() { drop.hidden = true; active = -1; }
    function links() { return drop.querySelectorAll('a.bk-s-item'); }
    function mark(i) {
      var all = links();
      all.forEach(function (a) { a.classList.remove('on'); });
      if (i >= 0 && all[i]) { all[i].classList.add('on'); all[i].scrollIntoView({ block: 'nearest' }); }
      active = i;
    }

    function show(data, q) {
      if (!data.groups || !data.groups.length) {
        drop.innerHTML = '<div class="bk-s-empty">Nothing found for “' + esc(q) + '”</div>';
      } else {
        drop.innerHTML = data.groups.map(function (g) {
          var more = g.total > g.items.length ? ' <span>' + g.total + ' found</span>' : ' <span>' + g.total + '</span>';
          return '<div class="bk-s-group">' + esc(g.title) + more + '</div>' +
            g.items.map(function (i) {
              return '<a class="bk-s-item" href="' + esc(i.url) + '"><b>' + esc(i.title) + '</b>' +
                (i.subtitle ? '<small>' + esc(i.subtitle) + '</small>' : '') + '</a>';
            }).join('');
        }).join('') +
        '<a class="bk-s-all" href="' + BASE + '?q=' + encodeURIComponent(q) + '">See all results for “' + esc(q) + '” →</a>';
      }
      drop.hidden = false;
      active = -1;
    }

    input.addEventListener('input', function () {
      var q = input.value.trim();
      clearTimeout(timer);
      if (q.length < 2) { close(); return; }
      timer = setTimeout(function () {
        last = q;
        fetch(BASE + '/suggest?q=' + encodeURIComponent(q), { credentials: 'same-origin', headers: { Accept: 'application/json' } })
          .then(function (r) { return r.ok ? r.json() : { groups: [] }; })
          .then(function (data) { if (q === last && input.value.trim() === q) show(data, q); })
          .catch(function () {});
      }, 250);
    });

    input.addEventListener('keydown', function (e) {
      var all = links();
      if (e.key === 'ArrowDown' && !drop.hidden) { e.preventDefault(); mark(Math.min(active + 1, all.length - 1)); }
      else if (e.key === 'ArrowUp' && !drop.hidden) { e.preventDefault(); mark(Math.max(active - 1, -1)); }
      else if (e.key === 'Enter' && active >= 0 && all[active]) { e.preventDefault(); window.location = all[active].href; }
      else if (e.key === 'Escape') { close(); }
    });
    input.addEventListener('focus', function () { if (drop.innerHTML && input.value.trim().length >= 2) drop.hidden = false; });
    document.addEventListener('click', function (e) { if (!li.contains(e.target)) close(); });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', setup);
  else setup();
})();
