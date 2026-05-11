ActiveAdmin.register MarriageProfile do
  permit_params :verified

  menu parent: 'User'

  member_action :print_profile, method: :get do
    @profile = MarriageProfile.friendly.find(params[:id])
    render 'admin/marriage_profiles/print_profile', layout: false
  end

  action_item :print_profile, only: :show do
    link_to 'Biodata',
            print_profile_shefali007_marriage_profile_path(resource),
            target: '_blank',
            class: 'button'
  end

  show do
    attributes_table do
      row :name
      row :unique_id
      row :nid_or_passport
      row :about_my_self
      row :blood_group
      row :date_of_birth
      row :description
      row "Email" do |m| m.user.email end
      row :family_status
      row :family_type
      row :family_values
      row :gender
      row "Height" do |m| "#{m.height_ft} ft #{m.height_inch} inch" end
      row :highest_education_level
      row :hometown
      row :marital_status
      row :present_location
      row :present_address
      row :profile_completeness
      row :relation
      row :religion
      row :special_circumstances
      row :verified
      row :created_at
      row :updated_at
      row "Photos" do |m|
        [m.photo_1.present? ? image_tag(m.photo_1.url(:thumb)) : nil,
         m.photo_2.present? ? image_tag(m.photo_2.url(:thumb)) : nil,
         m.photo_3.present? ? image_tag(m.photo_3.url(:thumb)) : nil]
      end
      row "Identification Document" do |m|
        m.identification_document.present? ? link_to(image_tag(m.identification_document.url, height: 200), m.identification_document.url, target: '_blank') : nil
      end
      row "Partner Preference — Gender" do |m|
        m.partner_preference&.gender&.titleize
      end
      row "Partner Preference — Age Range" do |m|
        pp = m.partner_preference
        pp.present? ? "#{pp.min_age} – #{pp.max_age} years" : '-'
      end
      row "Partner Preference — Religion" do |m|
        m.partner_preference&.religion&.map(&:to_s)&.map(&:titleize)&.join(', ')
      end
      row "Partner Preference — Marital Status" do |m|
        m.partner_preference&.marital_status&.map(&:to_s)&.map(&:titleize)&.join(', ')
      end
      row "Partner Preference — Education" do |m|
        m.partner_preference&.highest_education_level&.to_s&.titleize
      end
      row "Partner Preference — Family Type" do |m|
        m.partner_preference&.family_type&.titleize
      end
      row "Partner Preference — Family Status" do |m|
        m.partner_preference&.family_status&.to_s&.titleize
      end
      row "Partner Preference — Physical Status" do |m|
        m.partner_preference&.physical_status&.titleize
      end
      row "Partner Preference — Blood Group" do |m|
        [m.partner_preference&.blood_group].flatten.compact.join(', ').presence || '-'
      end
      row "Partner Preference — Location" do |m|
        [m.partner_preference&.present_location].flatten.compact.join(', ').presence || '-'
      end
      row "Partner Preference — Hometown" do |m|
        [m.partner_preference&.hometown].flatten.compact.join(', ').presence || '-'
      end
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :unique_id
    column :user
    column :verified
    column :created_at
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
