ActiveAdmin.register Contact do
 permit_params :content, :address, :contact, :heading, :heading_bn, :content_bn
 menu parent: 'Manage Site'
 actions :all, :except => [:new, :create, :destroy]
end
