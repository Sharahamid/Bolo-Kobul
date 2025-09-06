ActiveAdmin.register Contact do
 permit_params :content, :address, :contact, :heading
 menu parent: 'Manage Site'
 actions :all, :except => [:new, :create, :destroy]
end
