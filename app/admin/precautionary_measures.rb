ActiveAdmin.register PrecautionaryMeasure do
  menu parent: 'Manage Site'
  permit_params :title, :content, :display_order

  form do |f|
    f.semantic_errors
    f.inputs do
      input :title, as: :string
      input :content, as: :ckeditor, label: false
      input :display_order, as: :number
    end
    f.actions
  end
end
