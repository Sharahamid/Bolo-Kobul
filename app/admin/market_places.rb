ActiveAdmin.register MarketPlace do
  permit_params :name , :status, :cost, :costing_unit, :facility, :link,
                :policy, :experience, :about, :service_coverage, :image, :image2, :image3, :location, :market_place_type_id

  show do
    attributes_table do
      row :name, as: :string
      row :location, as: :string
      row :status, as: :string
      row :market_place_type
      row :cost, as: :string
      row :costing_unit, as: :string
      row :facility, as: :text
      row :policy, as: :text
      row :experience, as: :text
      row :about, as: :text
      row :link, as: :link
      row('Image') { |m| admin_image_or_none(m, :image) }
      row('Image 2') { |m| admin_image_or_none(m, :image2) }
      row('Image 3') { |m| admin_image_or_none(m, :image3) }
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :name, as: :string
      input :status, as: :select
      input :market_place_type
      input :cost, as: :number
      input :costing_unit, as: :string
      input :location, as: :select, collection: District&.all&.map{|d| ["#{d&.name&.humanize}", d.name]}
      input :facility, as: :text
      input :policy, as: :text
      input :experience, as: :text
      input :about, as: :text
      input :link, as: :string
      input :image, as: :file, label: 'Image (main)', hint: admin_image_hint(f.object, :image)
      input :image2, as: :file, label: 'Image 2', hint: admin_image_hint(f.object, :image2)
      input :image3, as: :file, label: 'Image 3', hint: admin_image_hint(f.object, :image3)
    end
    f.actions
  end
end
