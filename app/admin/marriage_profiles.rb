ActiveAdmin.register MarriageProfile do
  permit_params :verified
  show do
    attributes_table do
      row :name, as: :string
      row :nid_or_passport, as: :string
      row :about_my_self, as: :text
      row :unique_id, as: :string
      row :blood_group, as: :string
      row :date_of_birth, as: :string
      row :description, as: :string
      row :email do |m|
        m.user.email
      end
      row :family_status, as: :string
      row :family_type, as: :string
      row :family_values, as: :string
      row :gender, as: :string
      row :height_ft, as: :string
      row :height_inch, as: :string
      row :highest_education_level, as: :string
      row :hometown, as: :text
      row :marital_status, as: :string
      row :marital_status, as: :string
      row :present_location, as: :text
      row :present_address, as: :text
      row :profile_completeness, as: :string
      row :relation, as: :string
      row :religion, as: :string
      row :slug, as: :string
      row :special_circumstances, as: :text
      row :verified, as: :string
      row :created_at, as: :string
      row :updated_at, as: :string
      row "Photos" do |m|
        [m.photo_1.present? ? image_tag(m.photo_1.url(:thumb)) : nil,
         m.photo_2.present? ? image_tag(m.photo_2.url(:thumb)) : nil,
         m.photo_3.present? ? image_tag(m.photo_3.url(:thumb)) : nil]
      end
      row "Identification Document" do |m|
        m.identification_document.present? ? link_to(image_tag(m.identification_document.url, height: 200), m.identification_document.url, target: '_blank') : nil
      end
      row "Other Supporting Doc" do |m|
        image_tag m.other_supporting_doc_url
      end
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :unique_id
    column :user
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :verified, as: :select
    end
    f.actions
  end
end
