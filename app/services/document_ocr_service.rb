class DocumentOcrService
  def self.verify(profile)
    return :no_doc unless profile&.identification_document.present?

    doc_path = profile.identification_document.path
    return :no_doc unless doc_path && File.exist?(doc_path)

    extracted_text = extract_text(doc_path)
    return :unreadable if extracted_text.blank?

    user = profile.user
    matched = matches_any?(extracted_text, profile, user)

    matched ? :verified : :unverified
  end

  def self.extract_text(file_path)
    ext = File.extname(file_path).downcase
    work_path = file_path

    # Convert PDF to image if needed
    if ext == '.pdf'
      work_path = "/tmp/ocr_doc_#{SecureRandom.hex(6)}.png"
      system("convert -density 200 '#{file_path}[0]' '#{work_path}' 2>/dev/null")
      return '' unless File.exist?(work_path)
    end

    output_base = "/tmp/ocr_output_#{SecureRandom.hex(6)}"

    # Run tesseract with both English and Bengali
    system("tesseract '#{work_path}' '#{output_base}' -l eng+ben --psm 3 quiet 2>/dev/null")

    text = File.exist?("#{output_base}.txt") ? File.read("#{output_base}.txt") : ''

    # Cleanup
    File.delete("#{output_base}.txt") rescue nil
    File.delete(work_path) if work_path != file_path rescue nil

    text.downcase.gsub(/[^a-z0-9\s]/, ' ').squeeze(' ').strip
  end

  def self.matches_any?(text, profile, user)
    checks = []

    # Check name — split into parts, any part matches
    if user.name.present?
      name_parts = user.name.downcase.split(' ').select { |p| p.length > 2 }
      checks << name_parts.any? { |part| text.include?(part) }
    end

    # Check NID/Passport number from marriage profile
    if profile.nid_or_passport.present?
      nid = profile.nid_or_passport.to_s.downcase.gsub(/\s/, '')
      checks << text.gsub(/\s/, '').include?(nid)
    end

    # Check national_id from user
    if user.national_id.present?
      nid = user.national_id.to_s.downcase.gsub(/\s/, '')
      checks << text.gsub(/\s/, '').include?(nid)
    end

    # Check date of birth
    if profile.date_of_birth.present?
      dob = profile.date_of_birth
      formats = [
        dob.strftime('%d/%m/%Y'),
        dob.strftime('%d-%m-%Y'),
        dob.strftime('%Y-%m-%d'),
        dob.strftime('%d %m %Y'),
        dob.year.to_s
      ]
      checks << formats.any? { |f| text.include?(f.downcase) }
    end

    checks.any?
  end
end
