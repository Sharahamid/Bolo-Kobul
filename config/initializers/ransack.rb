# Search filters (ransack) are only used by the admin panel. Since ransack 4, every
# model must list the fields it can be filtered on. Admins may filter on any field
# except passwords and secret tokens; this covers the app's models and those that come
# with gems (uploaded files, Kobul friendships, admin permissions...).
module AdminFilterableFields
  HIDDEN = %w[encrypted_password reset_password_token confirmation_token
              unlock_token remember_token otp_secret].freeze

  def ransackable_attributes(_auth_object = nil)
    column_names - HIDDEN
  end

  def ransackable_associations(_auth_object = nil)
    reflect_on_all_associations.map { |association| association.name.to_s }
  end
end

ActiveSupport.on_load(:active_record) do
  extend AdminFilterableFields
end
