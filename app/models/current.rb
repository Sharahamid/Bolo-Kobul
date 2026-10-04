# Per-request state, reset automatically after every request
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :remember_in_app
end
