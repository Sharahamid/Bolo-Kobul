ActiveAdmin.register Blog do
  permit_params :author, :partner, :title, :email, :married_life_duration,
                :story, :status, :image, :story_type

  index do
    id_column
    column :author
    column :partner
    column :title
    column :story_type
    column :slug
    column :status
    actions
  end

  show do
    attributes_table do
      row :author, as: :string
      row :partner, as: :string
      row :title, as: :string
      row :story_type, as: :string
      row :slug, as: :string
      row :email, as: :string
      row :married_life_duration, as: :string
      row :story, as: :text
      row :status, as: :string
      row "Image" do |image|
        image_tag image.image_url
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :author, as: :string
      input :partner, as: :string
      input :title, as: :string
      input :story_type, as: :select
      input :email, as: :string
      input :married_life_duration, as: :string
      input :story, as: :text
      input :status, as: :select
      input :image, as: :file
    end
    f.actions
  end
end
