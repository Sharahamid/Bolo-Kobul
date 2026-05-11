ActiveAdmin.register User do
  permit_params :name, :country_code, :phone_number, :national_id, :verified,
                :email, :username, :butterfly_number, :block_butterfly_number

  menu parent: 'User'

  filter :name
  filter :email
  filter :phone_number
  filter :created_for, as: :select, collection: User.created_fors.keys.map { |k| [k.titleize, k] }
  filter :verified
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :phone_number
    column "Created For" do |user|
      color = case user.created_for
              when 'self'               then '#D4EDDA'
              when 'parents', 'children' then '#D0E8FF'
              when 'sibling', 'relative' then '#FFF3CC'
              when 'friend', 'colleague' then '#FFE0B2'
              when 'other_as_matchmaker' then '#F8D7DA'
              else '#f0f0f0'
              end
      text_color = case user.created_for
                   when 'self'               then '#155724'
                   when 'parents', 'children' then '#0c5460'
                   when 'sibling', 'relative' then '#856404'
                   when 'friend', 'colleague' then '#7c4d00'
                   when 'other_as_matchmaker' then '#721c24'
                   else '#555'
                   end
      label = user.created_for&.titleize || 'Unknown'
      raw("<span style='background:#{color}; color:#{text_color}; padding:2px 8px; border-radius:10px; font-size:11px; font-weight:600;'>#{label}</span>")
    end
    column :verified
    column :butterfly_number
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :phone_number
      row "Created For" do |user|
        user.created_for&.titleize
      end
      row :verified
      row :otp
      row :butterfly_number
      row :block_butterfly_number
      row :created_at
    end
  end

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
