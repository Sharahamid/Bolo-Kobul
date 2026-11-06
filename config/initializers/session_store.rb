# Keep members signed in for 2 weeks, even when the phone closes the app or browser.
# Without an expiry the sign-in cookie vanished whenever Android closed the Bolo Kobul
# app, so a login or sign-up form reopened afterwards failed its security check.
# (Same cookie name as before, so nobody is signed out by this change.)
Rails.application.config.session_store :cookie_store, key: '_bolokobul_session', expire_after: 14.days
