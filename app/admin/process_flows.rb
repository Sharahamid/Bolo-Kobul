ActiveAdmin.register ProcessFlow do
  menu parent: 'Manage Site'
  permit_params :title, :content, :process_image

  form do |f|
    f.semantic_errors
    f.inputs do
      input :title, as: :string
      input :process_image, as: :file
      input :display_order, as: :number
    end
    f.actions
  end

  show do
    attributes_table do
      row :title, as: :string
      row :display_order, as: :number
      row "Process Image" do |process_flow|
        image_tag process_flow.process_image_url
      end
    end
  end
end
