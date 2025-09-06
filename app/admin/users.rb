ActiveAdmin.register User do
  permit_params :name, :country_code, :phone_number, :national_id, :verified,
                :email, :username, :butterfly_number, :block_butterfly_number
  menu parent: 'User'
  form do |f|
    f.semantic_errors
    f.inputs do
      input :name, as: :string
      input :phone_number, as: :string
      input :national_id, as: :string
      input :verified, as: :select
      input :butterfly_number, as: :number
      input :block_butterfly_number, as: :number
    end
    f.actions
  end
end
