# "Already have a biodata?" on the Basics step: reads the uploaded biodata with free tools on
# the server (BiodataReader) and sends back the details found, so the page can fill the form.
# Nothing is saved to the profile here; the file waits in a temporary folder and is kept with
# the profile only when the member presses Next.
class BiodataController < ApplicationController
  before_action :authenticate_user!
  rate_limit to: 6, within: 10.minutes, only: :read,
             with: -> { render json: { error: I18n.t('biodata.too_many') }, status: :too_many_requests }

  def read
    file = params[:file]
    return render(json: { error: I18n.t('biodata.no_file') }, status: :unprocessable_entity) unless file.respond_to?(:path)

    ext = File.extname(file.original_filename.to_s).downcase
    unless %w[.pdf .docx .jpg .jpeg .png .webp].include?(ext)
      return render json: { error: I18n.t('biodata.wrong_type') }, status: :unprocessable_entity
    end
    if file.size > 10_000_000
      return render json: { error: I18n.t('form.file_too_large', mb: 10) }, status: :unprocessable_entity
    end

    uploader = BiodataUploader.new
    uploader.cache!(file)
    result = BiodataReader.read(uploader.file.path, file.original_filename)

    render json: {
      cache: uploader.cache_name,
      fields: result[:fields],
      extras: result[:extras],
      found: result[:found],
      text_found: result[:text_found]
    }
  rescue CarrierWave::IntegrityError, CarrierWave::ProcessingError
    render json: { error: I18n.t('biodata.wrong_type') }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error "[biodata] read failed: #{e.class}: #{e.message}"
    render json: { error: I18n.t('biodata.failed') }, status: :unprocessable_entity
  end
end
