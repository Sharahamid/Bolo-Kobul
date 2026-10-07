ActiveAdmin.register ProcessFlow do
  menu parent: 'Manage Site'
  permit_params :title, :content, :process_image, :title_bn

  form do |f|
    f.semantic_errors
    f.inputs do
      input :title, as: :string
      input :title_bn, as: :string, label: 'Title (Bangla)', hint: 'Shown on the Bangla site. Leave empty to show the English title.'
      input :process_image, as: :file, hint: admin_image_hint(f.object, :process_image)
      input :display_order, as: :number
    end
    f.actions
  end

  show do
    attributes_table do
      row :title, as: :string
      row('Title (Bangla)') { |r| r.title_bn }
      row :display_order, as: :number
      row('Process Image') { |p| admin_image_or_none(p, :process_image) }
    end
  end
end
