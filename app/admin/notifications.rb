ActiveAdmin.register Notification do
  menu parent: 'Members', priority: 5
  filter :profile_id_eq, as: :string, label: 'Profile ID (BK…)'
  filter :recipient_email, as: :string, label: 'Member email'
  filter :is_read
  filter :created_at
  permit_params :content, :is_read, :assign_to

  form do |f|
    f.inputs do
      f.input :content
      f.input :is_read
      f.input :assign_to,
            as: :select,
            collection: (User.pluck(:id, :email).map{|i, e| ["u_#{e}", "#{i}__User"]}),
              selected: "#{f.object.recipient_id}__User",
              value: "#{f.object.recipient_id}"
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column('Message') { |n| admin_preview(n.content, 70) }
    column :notifiable
    column :user
    column :recipient
    column :is_read
    column :will_email
    column :will_sms
    column :created_at
    actions
  end
end
