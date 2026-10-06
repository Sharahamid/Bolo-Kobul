ActiveAdmin.register ProfileReport do
  menu parent: 'User', label: 'Profile Reports'
  actions :index, :show, :edit, :update
  permit_params :status, :admin_note

  config.sort_order = 'created_at_desc'

  scope :all
  scope('Needs review', default: true) { |reports| reports.unresolved }

  filter :reason, as: :select, collection: -> { ProfileReport::REASONS.invert }
  filter :status, as: :select, collection: ProfileReport::STATUSES
  filter :created_at

  index do
    id_column
    column('Reported') { |r| link_to r.reported_profile.unique_id, shefali007_marriage_profile_path(r.reported_profile) rescue r.reported_profile_id }
    column('Reason', &:reason_label)
    column('Reports on this profile', &:reporter_count)
    column('By') { |r| r.reporter_profile&.unique_id || 'Deleted member' }
    column :status
    column('Reported at') { |r| r.created_at.in_time_zone('Asia/Dhaka').strftime('%-d %b %Y, %-I:%M %p') }
    actions
  end

  show do
    attributes_table do
      row('Reported profile') { |r| link_to r.reported_profile.unique_id, shefali007_marriage_profile_path(r.reported_profile) rescue r.reported_profile_id }
      row('Reported member') { |r| "#{r.reported_profile.user&.name} (#{r.reported_profile.user&.email}, #{r.reported_profile.user&.phone_number})" }
      row('Account deactivated') { |r| r.reported_profile.user&.deactivated ? 'Yes' : 'No' }
      row('Reason', &:reason_label)
      row :details
      row('Reported by') { |r| r.reporter_profile&.unique_id || 'Deleted member' }
      row('Reports on this profile', &:reporter_count)
      row :status
      row :admin_note
      row :created_at
    end
  end

  form do |f|
    f.inputs do
      f.input :status, as: :select, collection: ProfileReport::STATUSES, include_blank: false
      f.input :admin_note, hint: 'Only visible to admins'
    end
    f.actions
  end

  action_item :deactivate, only: :show, if: proc { resource.reported_profile.user && !resource.reported_profile.user.deactivated } do
    link_to 'Deactivate reported account', deactivate_account_shefali007_profile_report_path(resource), method: :patch,
            data: { confirm: 'Hide this member from everyone and mark the report "action taken"?' }
  end

  member_action :deactivate_account, method: :patch do
    resource.reported_profile.user&.update_columns(deactivated: true)
    resource.update(status: 'action_taken')
    redirect_to resource_path, notice: 'Account deactivated. The member no longer appears to anyone.'
  end
end
