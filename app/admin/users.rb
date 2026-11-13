ActiveAdmin.register User do
  permit_params :name, :country_code, :phone_number, :national_id, :verified,
                :email, :username, :butterfly_number, :block_butterfly_number, :bk_plus_until,
                :admin_message, :admin_message_action

  menu parent: 'Members', priority: 1
  filter :profile_id_eq, as: :string, label: 'Profile ID (BK…)'
  filter :name
  filter :email
  filter :phone_number
  filter :created_for, as: :select, collection: User.created_fors.keys.map { |k| [k.titleize, k] }
  filter :verified
  filter :created_at

  index do
    selectable_column
    id_column
    # Name, email and phone in one cell so the list fits the screen
    column('Member', sortable: :name) do |user|
      raw("<b>#{ERB::Util.html_escape(user.name)}</b><br><small style='color:#7A7368'>#{ERB::Util.html_escape(user.email)}<br>#{ERB::Util.html_escape(user.phone_number)}</small>")
    end
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
        links = " "
        links += link_to("View", shaheer10inara20_marriage_profile_path(profile), style: "font-size:12px; margin-right:5px;")
        links += link_to("✅", verify_doc_shaheer10inara20_user_path(user, status: 1), method: :patch, style: "margin-right:3px;", title: "Mark Verified")
        links += link_to("❌", verify_doc_shaheer10inara20_user_path(user, status: 2), method: :patch, style: "margin-right:3px;", title: "Mark Unverified")
        raw(icon + links)
      else
        raw("<span style='color:#ccc;'>No Doc</span>")
      end
    end
    column :verified
    column('Butterflies', sortable: :butterfly_number) { |user| user.butterfly_number }
    # BK+ and account deletion together, shown only when they apply
    column('BK+ / Deletion') do |user|
      tags = []
      tags << "<span class='status_tag yes'>BK+ until #{user.bk_plus_until.in_time_zone('Asia/Dhaka').strftime('%-d %b %Y')}</span>" if user.bk_plus?
      tags << "<span class='status_tag no'>Deleting #{user.deletion_date.strftime('%-d %b %Y')}</span>" if user.deletion_scheduled?
      raw(tags.join(' '))
    end
    column('Joined', sortable: :created_at) { |user| user.created_at.in_time_zone('Asia/Dhaka').strftime('%-d %b %Y') }
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
      row("BK+ until") { |user| user.bk_plus_until ? "#{user.bk_plus_until.in_time_zone('Asia/Dhaka').strftime('%-d %b %Y, %l:%M %p')}#{' (expired)' unless user.bk_plus?}" : 'No' }
      row("Daily nudges") { |user| user.nudges_enabled ? 'On' : 'Off' }
      row("Message from the team") do |user|
        if user.admin_message.present?
          status = if user.admin_message_waiting?
                     "<span class='status_tag pending'>Not seen yet</span>"
                   else
                     "<span class='status_tag yes'>Seen #{user.admin_message_seen_at&.in_time_zone('Asia/Dhaka')&.strftime('%-d %b %Y, %-I:%M %p')}</span>"
                   end
          raw("#{status}<br>#{simple_format(ERB::Util.html_escape(user.admin_message))}<small style='color:#999'>Sent #{user.admin_message_sent_at&.in_time_zone('Asia/Dhaka')&.strftime('%-d %b %Y, %-I:%M %p')}</small>")
        else
          'None'
        end
      end
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

  member_action :auto_verify_doc, method: :patch do
    profile = resource.marriage_profiles.first
    if profile&.identification_document.present?
      result = DocumentOcrService.verify(profile)
      case result
      when :verified
        profile.update(doc_verification_status: 1)
        flash[:notice] = "OCR matched — document auto-verified ✅"
      when :unverified
        flash[:alert] = "OCR could not match name, NID, or date of birth ❌"
      when :unreadable
        flash[:alert] = "Document could not be read by OCR ⚠️"
      when :no_doc
        flash[:alert] = "No document found"
      end
    else
      flash[:alert] = "No document uploaded"
    end
    redirect_to admin_users_path
  end

  member_action :verify_doc, method: :patch do
    profile = resource.marriage_profiles.first
    if profile
      profile.update_column(:doc_verification_status, params[:status].to_i)
      flash[:notice] = "Document verification status updated."
    end
    redirect_to shaheer10inara20_users_path
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
      input :bk_plus_until, as: :datepicker, label: 'BK+ until (pick a future date to give BK+; clear it to remove)'
    end
    f.inputs 'Message to this member' do
      input :admin_message, as: :text, label: 'Message', input_html: { rows: 4, placeholder: 'e.g. Please update your profile photo with a real, clear photo of yourself.' },
            hint: 'Shown as a pop-up the next time this member opens Bolo Kobul (website or app), until they press OK. ' \
                  'Write in English or Bangla. Changing the text sends it again; clear it to remove a message not yet seen.'
      input :admin_message_action, as: :select, label: 'Button', include_blank: false,
            collection: User::ADMIN_MESSAGE_ACTIONS.map { |k, v| [v, k] }
    end
    f.actions
  end
end
