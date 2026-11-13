ActiveAdmin.register Blog do
  menu parent: 'Website', priority: 8, label: 'Blogs & Stories'
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
      row('Image') { |b| admin_image_or_none(b, :image) }
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
      # Word-style editor (bold, underline, headings, lists). Older stories typed as plain
      # text are turned into paragraphs first so their line breaks are not lost.
      story = f.object.story.to_s
      if story.present? && !story.match?(%r{<(p|br|div|li|h[1-6]|table)\b}i)
        story = simple_format(ERB::Util.html_escape(story), {}, sanitize: false)
      end
      input :story, as: :ckeditor, input_html: { value: story }
      input :status, as: :select
      input :image, as: :file, hint: admin_image_hint(f.object, :image)
    end
    f.actions
  end
end
