ActiveAdmin.register Ad do
  menu parent: 'Manage Site'
  permit_params :title, :url, :price, :location, :advertiser, :status, :image

  form do |f|
    f.semantic_errors
    f.inputs do
      input :title
      input :url
      input :price
      input :location
      input :advertiser
      input :status, as: :select, collection: Ad.statuses.keys
      input :image, as: :file
    end
    f.actions
  end

  index do
    id_column
    column :title
    column :url
    column :price
    column :location
    column :advertiser
    column :status
    actions
  end

  show do
    attributes_table do
      row :title
      row :url
      row :price
      row :location
      row :advertiser
      row :image do |o|
        image_tag o.image_url, size:'200*200'
      end
      row :status
    end
  end
end

#  id                    :bigint           not null, primary key
#  location              :integer          default("home_page_left")
#  price                 :integer          default(0)
#  status                :integer          default("pending")
#  title                 :string
#  url                   :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  advertiser            :string
#