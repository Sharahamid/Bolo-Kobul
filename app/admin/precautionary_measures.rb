ActiveAdmin.register PrecautionaryMeasure do
  menu parent: 'Manage Site'
  permit_params :title, :content, :title_bn, :content_bn, :display_order

  form do |f|
    f.semantic_errors
    f.inputs do
      input :title, as: :string
      input :content, as: :ckeditor, label: false
      input :title_bn, as: :string, label: 'Title (Bangla)', hint: 'Shown on the Bangla site. Leave empty to show the English title.'
      input :content_bn, as: :ckeditor, label: 'Content (Bangla) — leave empty to show the English content'
      input :display_order, as: :number
    end
    f.actions
  end
end
