ActiveAdmin.register Contact do
 permit_params :content, :address, :contact, :heading, :heading_bn, :content_bn
 menu parent: 'Website', priority: 2, label: 'Contact page'
 actions :all, :except => [:new, :create, :destroy]

  index do
    id_column
    column :heading
    column :contact
    column('Preview') { |c| admin_preview(c.content) }
    column('Updated') { |c| c.updated_at.in_time_zone('Asia/Dhaka').strftime('%-d %b %Y') }
    actions
  end
end
