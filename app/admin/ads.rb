ActiveAdmin.register Ad do
  menu parent: 'Manage Site'
  permit_params :title, :url, :price, :location, :advertiser, :status, :image

  form do |f|
    f.semantic_errors
    f.inputs do
      input :title
      input :url, hint: 'Ads that link to the butterfly purchase page (/orders/new) are hidden in the Google Play app. All other ads show everywhere.'
      input :price
      input :location
      input :advertiser
      input :status, as: :select, collection: Ad.statuses.keys
      input :image, as: :file, hint: admin_image_hint(f.object, :image)
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
    column('Picture') { |o| o.image.attached? ? image_tag(rails_blob_path(o.image, only_path: true), style: 'max-width:90px; max-height:60px; border-radius:4px;') : 'none' }
    actions
  end

  show do
    attributes_table do
      row :title
      row :url
      row :price
      row :location
      row :advertiser
      row(:image) { |o| admin_image_or_none(o, :image) }
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