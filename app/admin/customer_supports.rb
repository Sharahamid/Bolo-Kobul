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
        column(:from) {|reply| reply.repliable_type}
        column :message
        column("Attachment") do |reply|
          if reply.attachment.attached?
            if reply.attachment.content_type.start_with?("image/")
              image_tag url_for(reply.attachment), width: 120, height: 120, style: "border-radius:6px; object-fit:cover;"
            else
              link_to "View File", url_for(reply.attachment), target: "_blank"
            end
          else
            "No attachment"
          end
        end
      end
    end

    panel 'New Reply' do
      active_admin_form_for resource.replies.build, url: reply_shefali007_customer_support_path, html: { multipart: true } do |f|
        f.semantic_errors(*f.object.errors.keys)
        f.inputs do
          f.input :message, as: :text
          f.input :attachment, as: :file, label: 'Attach Image/PDF (optional)'
        end
        f.actions do
          f.action :submit, label: 'Reply'
        end
      end
    end
  end

  member_action :reply, method: :post do
    reply = resource.replies.build(
      repliable: current_admin_user,
      message: params[:customer_support_reply][:message]
    )
    reply.attachment.attach(params[:customer_support_reply][:attachment]) if params[:customer_support_reply][:attachment].present?
    reply.save!

    resource.user.notifications.create(
      content: "There is an update on your Ticket No. # #{resource.id}. <a href='/customer_supports' style='color:#FFB627;font-weight:600;'>Show details</a>",
      notifiable: resource
    )

    redirect_to shefali007_customer_support_path(resource)
  end
end
