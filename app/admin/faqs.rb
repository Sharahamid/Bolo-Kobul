ActiveAdmin.register Faq do
  menu parent: 'Manage Site'
  permit_params :title, :content, :title_bn, :content_bn, :pdf_content, :display_order

  # generate custom link
  action_item :remove_pdf, only: [:show, :edit] do
    link_to "Remove PDF", remove_pdf_shefali007_faq_path
  end

  # define route
  member_action :remove_pdf, method: :get do;  end

  # customized controller method
  controller do
    def remove_pdf
      faq = Faq.find(params[:id])
      pdf_attachment = faq.pdf_content_attachment
      pdf_attachment.purge_later if pdf_attachment.present?
      redirect_to shefali007_faq_path(faq)
    end
  end

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

  show do
    attributes_table do
      row :title, as: :string
      row :content, as: :text
      row('Title (Bangla)') { |r| r.title_bn }
      row('Content (Bangla)') { |r| r.content_bn&.html_safe }
      row :display_order, as: :number
      row :pdf_content_url, as: :image
    end
  end

  index do
    selectable_column
    id_column
    column :title
    column :content do |tou|
      truncate(tou.content, length: 50)
    end
    column :display_order
    column :pdf_content_url do |tou|
      if tou.pdf_content_url.present?
        link_to "See File", tou.pdf_content_url, target: "_blank"
      end
    end
    column :updated_at
    actions
  end
end
