# Admin forms: browsers never show an already-saved file in a "Choose file" box, so
# each picture field shows the current picture next to it
module AdminImagesHelper
  PREVIEW_STYLE = 'display:block; max-width:240px; max-height:180px; border-radius:6px; border:1px solid #ddd; margin:6px 0; background:#fff;'.freeze

  def admin_image_preview(record, attachment)
    file = record.public_send(attachment)
    return nil unless file.attached?

    image_tag(rails_blob_path(file, only_path: true), style: PREVIEW_STYLE, alt: file.filename.to_s)
  end

  # Hint under the upload box: the current picture, or a note that there is none yet
  def admin_image_hint(record, attachment)
    preview = admin_image_preview(record, attachment)
    if preview
      safe_join([preview, "Current picture: #{record.public_send(attachment).filename}. Leave this empty to keep it, or choose a file to replace it."])
    else
      'No picture yet. Choose a file to add one.'
    end
  end

  # For show pages: the picture, or "No picture"
  def admin_image_or_none(record, attachment)
    admin_image_preview(record, attachment) || 'No picture'
  end
end
