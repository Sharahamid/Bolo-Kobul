module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    # Use the user signed in through Devise; reject anyone who is not signed in
    def find_verified_user
      env['warden']&.user(:user) || reject_unauthorized_connection
    end
  end
end
