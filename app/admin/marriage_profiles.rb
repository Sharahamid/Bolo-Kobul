ActiveAdmin.register MarriageProfile do
  # Admin can correct a member's details (Edit button on a profile)
  EDITABLE = %i[verified gender date_of_birth height_ft height_inch religion other_religion marital_status
                highest_education_level other_education blood_group hometown present_location
                family_type family_values family_status about_my_self special_circumstances].freeze
  permit_params(*EDITABLE)

  controller do
    # Older profiles can miss things the member form now requires (e.g. an ID file), which
    # would stop every correction. Admin changes are saved without those checks, but a date
    # of birth under the legal age (21 for men, 18 for women) is still refused.
    def update
      resource.assign_attributes(permitted_params[:marriage_profile] || {})
      min_age = MarriageProfile.minimum_age_for(resource.gender)
      if resource.date_of_birth.present? && resource.date_of_birth.to_date > min_age.years.ago.to_date
        resource.errors.add(:date_of_birth, "makes this person younger than #{min_age} (minimum #{min_age} for #{resource.male? ? 'men' : 'women'})")
        return render :edit
      end
      if resource.save(validate: false)
        resource.calculate_profile_completeness! if resource.respond_to?(:calculate_profile_completeness!)
        redirect_to resource_path(resource), notice: "#{resource.unique_id} saved. The member sees the change straight away."
      else
        render :edit
      end
    end
  end

  menu parent: 'Members', priority: 2
  filter :profile_id_eq, as: :string, label: 'Profile ID (BK…)'
  filter :name
  filter :gender, as: :select, collection: -> { MarriageProfile.genders.keys.map { |k| [k.titleize, MarriageProfile.genders[k]] } }
  filter :religion, as: :select, collection: -> { MarriageProfile.religions.keys.map { |k| [k.titleize, MarriageProfile.religions[k]] } }
  filter :marital_status, as: :select, collection: -> { MarriageProfile.marital_statuses.keys.map { |k| [k.humanize, MarriageProfile.marital_statuses[k]] } }
  filter :verified
  filter :doc_verification_status, as: :select, label: 'Doc check', collection: [['Waiting', 0], ['Verified', 1], ['Not verified', 2]]
  filter :created_at

  # Shows the member's ID document (NID or passport). The file is stored outside the public
  # folder, so this admin-only page is the only way to open it.
  member_action :id_document, method: :get do
    file = resource.identification_document.file
    return head(:not_found) unless file&.exists?

    response.headers['Cache-Control'] = 'private, no-store'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    send_file file.path, disposition: 'inline', type: Marcel::MimeType.for(Pathname.new(file.path), name: file.filename)
  end

  # The member's own biodata (uploaded on the Basics step). Private like the ID document.
  member_action :biodata_document, method: :get do
    file = resource.biodata_document.file
    return head(:not_found) unless file&.exists?

    response.headers['Cache-Control'] = 'private, no-store'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    send_file file.path, disposition: 'inline', type: Marcel::MimeType.for(Pathname.new(file.path), name: file.filename)
  end

  member_action :print_profile, method: :get do
    @profile = MarriageProfile.friendly.find(params[:id])
    render 'admin/marriage_profiles/print_profile', layout: false
  end

  action_item :print_profile, only: :show do
    link_to 'Biodata',
            print_profile_shaheer10inara20_marriage_profile_path(resource),
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
      row "Biodata file (uploaded by the member)" do |m|
        if m.biodata_document.present?
          link_to("Open biodata (#{File.extname(m.biodata_document.file.filename.to_s).delete('.').upcase})", m.biodata_document.url, target: '_blank', class: 'button')
        else
          'None uploaded'
        end
      end
      row "Details read from the biodata" do |m|
        extras = (m.biodata_data || {})['extras'] || {}
        extras.present? ? raw(extras.map { |k, v| "<b>#{ERB::Util.html_escape(k.to_s.humanize)}:</b> #{ERB::Util.html_escape(v)}" }.join('<br>')) : '-'
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
      row "Partner Preference — Minimum Education" do |m|
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
    f.semantic_errors(*f.object.errors.attribute_names)
    titled = ->(enum) { MarriageProfile.send(enum).keys.map { |k| [k.to_s.tr('_', ' ').capitalize, k] } }
    f.inputs "Correct #{f.object.unique_id}'s details" do
      f.input :verified, as: :select
      f.input :gender, as: :select, collection: titled.call(:genders), include_blank: false
      f.input :date_of_birth, as: :datepicker, hint: 'Men must be 21 or older, women 18 or older.'
      f.input :height_ft, as: :select, label: 'Height: feet', collection: (4..7).map { |n| [n.to_s, n.to_s] }, include_blank: false
      f.input :height_inch, as: :select, label: 'Height: inches', collection: (0..11).map { |n| [n.to_s, n.to_s] }, include_blank: false
      f.input :religion, as: :select, collection: titled.call(:religions)
      f.input :other_religion, hint: 'Only when Religion is Other.'
      f.input :marital_status, as: :select, collection: titled.call(:marital_statuses)
      f.input :highest_education_level, as: :select, label: 'Education', collection: titled.call(:highest_education_levels)
      f.input :other_education, hint: 'Only when Education is Other.'
      f.input :blood_group, as: :select, collection: MarriageProfile.blood_groups.keys.map { |k| [k, k] }
      f.input :hometown, as: :string, hint: 'District, as the member chose it (e.g. Khulna).'
      f.input :present_location, as: :string, label: 'Present location'
      f.input :family_type, as: :select, collection: titled.call(:family_types)
      f.input :family_values, as: :select, collection: titled.call(:family_values)
      f.input :family_status, as: :select, collection: titled.call(:family_statuses)
      f.input :about_my_self, label: 'About me', input_html: { rows: 5 }
      f.input :special_circumstances, input_html: { rows: 3 }
    end
    f.actions do
      f.action :submit, label: 'Save changes'
      f.cancel_link
    end
  end
end
