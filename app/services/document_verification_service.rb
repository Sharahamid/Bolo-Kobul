class DocumentVerificationService
  MATCH_THRESHOLD = 0.6

  def self.verify(marriage_profile)
    new(marriage_profile).verify
  end

  def initialize(marriage_profile)
    @profile = marriage_profile
  end

  def verify
    return :no_document unless @profile.identification_document.present?

    doc_path = Rails.root.join('public', @profile.identification_document.to_s.gsub(/^\//, ''))
    return :file_not_found unless File.exist?(doc_path)

    text = extract_text(doc_path)
    return :extraction_failed if text.blank?

    matches = check_matches(text)
    result = matches[:name] || matches[:nid] ? :verified : :unverified
    @profile.update_column(:doc_verification_status, result == :verified ? 1 : 2)
    result
  rescue => e
    Rails.logger.error "DocumentVerificationService error: #{e.message}"
    :error
  end

  private

  def extract_text(path)
    ext = File.extname(path).downcase
    if ext == '.pdf'
      extract_from_pdf(path)
    elsif %w(.doc .docx).include?(ext)
      ''
    else
      extract_from_image(path)
    end
  end

  def extract_from_image(path)
    output = `tesseract #{Shellwords.escape(path.to_s)} stdout -l ben+eng 2>/dev/null`
    output.downcase
  end

  def extract_from_pdf(path)
    png_path = "#{path}.ocr.png"
    `convert -density 300 #{Shellwords.escape(path.to_s)}[0] -depth 8 #{Shellwords.escape(png_path)} 2>/dev/null`
    if File.exist?(png_path)
      text = extract_from_image(png_path)
      File.delete(png_path)
      text
    else
      ''
    end
  end

  def check_matches(text)
    {
      name: name_matches?(text),
      nid: nid_matches?(text)
    }
  end

  def name_matches?(text)
    return false if @profile.name.blank?
    name_parts = @profile.name.downcase.split
    matched = name_parts.count { |part| text.include?(part) }
    matched.to_f / name_parts.length >= MATCH_THRESHOLD
  end

  def nid_matches?(text)
    return false if @profile.nid_or_passport.blank?
    nid = @profile.nid_or_passport.to_s.gsub(/\s/, '')
    text.gsub(/\s/, '').include?(nid)
  end
end
