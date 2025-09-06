ActiveAdmin.register CustomerSupport do
  permit_params :status
  actions :all, :except => [:new, :create, :destroy]

  index do
    id_column
    column :user
    column :issue_type
    column :description
    column :status
    column "Customer Attachment" do |customer|
     image_tag customer.customer_attachment.attached? ? url_for(customer.customer_attachment) : '', width:'100', height:'100', class: 'customer_attachment'
    end
    actions
  end

  show do
    attributes_table do
      row :user
      row :issue_type
      row :description
      row :status
      row "Customer Attachment" do |customer|
        image_tag customer.customer_attachment.attached? ? url_for(customer.customer_attachment) : '', width:'400', height:'300', class: 'customer_attachment'
      end
    end

    panel "Replies" do
      table_for resource.replies do
        column(:replied_at) {|reply| reply.created_at}
        column :repliable_type
        column :repliable_id
        column :message
      end
    end

    panel 'New Reply' do
      active_admin_form_for resource.replies.build, url: reply_shefali007_customer_support_path do |f|
        f.semantic_errors(*f.object.errors.keys)
        f.inputs do
          f.input :message, as: :text
        end
        f.actions do
          f.action :submit, label: 'Reply'
        end
      end
    end
  end

  member_action :reply, method: :post do
    resource.replies.create(
      repliable: current_admin_user,
      message: params[:customer_support_reply][:message]
    )

    resource.user.notifications.create(
      content: "There is an update on your Ticket No. # #{resource.id}. <a href='#{customer_supports_url}'>Show details</a>",
      notifiable: resource
    )

    redirect_to shefali007_customer_support_path(resource)
  end
end
