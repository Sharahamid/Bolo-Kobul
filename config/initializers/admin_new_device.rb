# Email an admin when they sign in to the admin panel from a new browser or device
Warden::Manager.after_authentication(scope: :admin_user) do |admin, auth, _opts|
  request = ActionDispatch::Request.new(auth.env)
  AdminKnownDevice.check_sign_in(admin, request, request.cookie_jar)
end
