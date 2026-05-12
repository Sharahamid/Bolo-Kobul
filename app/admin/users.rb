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
    column "Doc Verified" do |user|
      profile = user.marriage_profiles.first
      if profile&.identification_document.present?
        doc_url = profile.identification_document.url
        status = profile.doc_verification_status
        icon = case status
               when 1 then "<span style='color:green; font-size:16px;' title='Verified'>✅</span>"
               when 2 then "<span style='color:red; font-size:16px;' title='Not Verified'>❌</span>"
               else "<span style='color:orange; font-size:16px;' title='Pending'>⚠️</span>"
               end
        links = "<br/>"
        links += link_to("View", shefali007_marriage_profile_path(profile), style: "font-size:11px; margin-right:5px;")
        links += link_to("✅", verify_doc_shefali007_user_path(user, status: 1), method: :patch, style: "margin-right:3px;", title: "Mark Verified")
        links += link_to("❌", verify_doc_shefali007_user_path(user, status: 2), method: :patch, style: "margin-right:3px;", title: "Mark Unverified")
        raw(icon + links)
      else
        raw("<span style='color:#ccc;'>No Doc</span>")
      end
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
      row "Identification Document" do |user|
        profile = user.marriage_profiles.first
        if profile&.identification_document.present?
          link_to "View Document", profile.identification_document.url, target: "_blank"
        else
          "No document uploaded"
        end
      end
      row "Document Verification" do |user|
        profile = user.marriage_profiles.first
        if profile
          case profile.doc_verification_status
          when 1 then status_tag "Verified", class: "yes"
          when 2 then status_tag "Not Verified", class: "no"
          else status_tag "Pending", class: "warning"
          end
        end
      end
      row :created_at
    end
  end

  member_action :verify_doc, method: :patch do
    profile = resource.marriage_profiles.first
    if profile
      profile.update_column(:doc_verification_status, params[:status].to_i)
      flash[:notice] = "Document verification status updated."
    end
    redirect_to shefali007_users_path
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
