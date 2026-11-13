# A member's own biodata (Basics step). Stored outside the public folder like the ID
# document: only admins can open it (Admin > Marriage Profiles > Biodata file).
class BiodataUploader < CarrierWave::Uploader::Base
  storage :file

  def root
    Rails.root.join('storage').to_s
  end

  def store_dir
    "biodata/#{model.class.to_s.underscore}/#{model.id}"
  end

  def cache_dir
    'biodata_tmp'
  end

  def url(*)
    return nil if file.blank? || model&.id.blank?

    Rails.application.routes.url_helpers.biodata_document_shaheer10inara20_marriage_profile_path(model)
  end

  def extension_whitelist
    %w[pdf docx jpg jpeg png webp]
  end

  def size_range
    1..10_000_000
  end
end
