ActiveAdmin.register About do
  menu parent: 'Manage Site'
  permit_params :content, :content_type, :display_order, :content_bn, :content_type_bn
  # actions :all, :except => [:new, :create, :destroy]
end
