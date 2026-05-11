ActiveAdmin.register About do
  menu parent: 'Manage Site'
  permit_params :content, :content_type, :display_order
  # actions :all, :except => [:new, :create, :destroy]
end
