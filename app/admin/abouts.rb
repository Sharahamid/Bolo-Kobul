ActiveAdmin.register About do
  menu parent: 'Website', priority: 1, label: 'About page'
  permit_params :content, :content_type, :display_order, :content_bn, :content_type_bn
  # actions :all, :except => [:new, :create, :destroy]

  config.sort_order = 'display_order_asc'

  index do
    id_column
    column('Section') { |a| a.content_type }
    column('Section (Bangla)') { |a| a.content_type_bn }
    column('Preview') { |a| admin_preview(a.content) }
    column :display_order
    column('Updated') { |a| a.updated_at.in_time_zone('Asia/Dhaka').strftime('%-d %b %Y') }
    actions
  end
end
