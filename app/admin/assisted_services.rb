ActiveAdmin.register AssistedService do
  menu parent: 'Manage Site'
  permit_params :name, :price, :page_title, :page_content, :display_order

  form do |f|
    f.semantic_errors
    f.inputs do
      input :name, as: :string
      input :price, as: :number
      input :page_title, as: :string
      input :page_content, as: :ckeditor, label: false
      input :display_order, as: :number
    end
    f.actions
  end

  show do
    attributes_table do
      row :name, as: :string
      row :price, as: :number
      row :page_title, as: :string
      row :page_content, as: :text
      row :display_order, as: :number
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :price
    column :page_title
    column :display_order
    column :updated_at
    actions
  end
end
