class IdentificationDocumentUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # ID documents (NID, passport) are private: they are kept in storage/id_documents, outside the
  # public folder, so the web server never serves them. Only admins can open them, through
  # /shefali007/marriage_profiles/:id/id_document. (Documents uploaded before this were moved
  # with: bin/rails id_documents:make_private)
  def root
    Rails.root.join('storage').to_s
  end

  def store_dir
    "id_documents/#{model.class.to_s.underscore}/#{model.id}"
  end

  # The admin-only address that shows the document
  def url(*)
    return nil if file.blank? || model&.id.blank?

    Rails.application.routes.url_helpers.id_document_shefali007_marriage_profile_path(model)
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process resize_to_limit: [512, 512]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(jpg jpeg gif png pdf doc docx)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  # protected
  # def image?(new_file)
  #   new_file.content_type.start_with? 'image'
  # end
end
