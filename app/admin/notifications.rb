ActiveAdmin.register Notification do
  menu parent: 'User'
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
    column :name
    column :notifiable
    column :user
    column :recipient
    column :is_read
    column :will_email
    column :will_sms
    column :created_at
    column :updated_at
    actions
  end
end
