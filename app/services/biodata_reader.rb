# Reads a member's own biodata (Word .docx, PDF or a photo) with free tools on the server and
# picks out the details a biodata usually has ("Label : Value", in English or Bangla).
#
#  - Word (.docx): text taken straight from the file
#  - PDF made on a computer: text taken straight from the file (pdftotext, poppler-utils)
#  - Photo or scanned PDF: the free text scanner (tesseract, English + Bangla)
#
# Returns { fields: {...form fields...}, extras: {...details for later profile steps...},
#           found: number of details found, text_found: true/false }.
# Phone numbers and full addresses are never returned.
require 'open3'

class BiodataReader
  MAX_PAGES = 3

  BN_DIGITS = '০১২৩৪৫৬৭৮৯'.freeze

  MONTHS = {
    'jan' => 1, 'feb' => 2, 'mar' => 3, 'apr' => 4, 'may' => 5, 'jun' => 6,
    'jul' => 7, 'aug' => 8, 'sep' => 9, 'oct' => 10, 'nov' => 11, 'dec' => 12,
    'জানু' => 1, 'ফেব্রু' => 2, 'মার্চ' => 3, 'এপ্রিল' => 4, 'মে' => 5, 'জুন' => 6,
    'জুলাই' => 7, 'আগস্ট' => 8, 'আগষ্ট' => 8, 'সেপ্ট' => 9, 'অক্টো' => 10, 'নভে' => 11, 'ডিসে' => 12
  }.freeze

  # Older English spellings of district names
  DISTRICT_ALIASES = {
    'chittagong' => 'chattogram', 'comilla' => 'cumilla', 'barisal' => 'barishal', 'bogra' => 'bogura',
    'jessore' => 'jashore', 'cox s bazar' => 'coxsbazar', 'coxs bazar' => 'coxsbazar', 'cox bazar' => 'coxsbazar',
    'jhalokati' => 'jhalakathi', 'jhalokathi' => 'jhalakathi', 'nawabganj' => 'chapainawabganj',
    'chapai nawabganj' => 'chapainawabganj', 'netrakona' => 'netrokona', 'maulvibazar' => 'moulvibazar',
    'moulvi bazar' => 'moulvibazar', 'brahmanbaria' => 'brahmanbaria', 'b baria' => 'brahmanbaria',
    'lakshmipur' => 'lakshmipur', 'laxmipur' => 'lakshmipur', 'khagrachari' => 'khagrachhari'
  }.freeze

  # Labels: the first matching rule wins, so the more specific ones come first
  LABELS = [
    [:father_name,       /\A(father'?s?\s*name|name\s*of\s*(the\s*)?father|পিতার\s*নাম|বাবার\s*নাম)/i],
    [:father_occupation, /\A(father'?s?\s*(occupation|profession|job)|পিতার\s*পেশা|বাবার\s*পেশা)/i],
    [:father,            /\A(father|পিতা|বাবা)\b?/i],
    [:mother_name,       /\A(mother'?s?\s*name|name\s*of\s*(the\s*)?mother|মাতার\s*নাম|মায়ের\s*নাম|মায়ের\s*নাম)/i],
    [:mother_occupation, /\A(mother'?s?\s*(occupation|profession|job)|মাতার\s*পেশা|মায়ের\s*পেশা|মায়ের\s*পেশা)/i],
    [:mother,            /\A(mother|মাতা|মা)\b?/i],
    [:siblings,          /\A(siblings?|brothers?\s*(and|&|\/)\s*sisters?|brothers?|sisters?|ভাই\s*-?\s*বোন|ভাইবোন|ভাই|বোন)/i],
    [:dob,               /\A(date\s*of\s*birth|birth\s*date|d\.?\s*o\.?\s*b\.?|জন্ম\s*তারিখ|জন্মতারিখ|জন্ম\s*দিন)/i],
    [:age,               /\A(age|বয়স|বয়স)/i],
    [:height,            /\A(height|উচ্চতা)/i],
    [:weight,            /\A(weight|ওজন)/i],
    [:religion,          /\A(religion|ধর্ম)/i],
    [:marital_status,    /\A(marital\s*status|বৈবাহিক\s*অবস্থা)/i],
    [:gender,            /\A(gender|sex|লিঙ্গ)/i],
    [:blood_group,       /\A(blood\s*group|রক্তের\s*গ্রুপ|রক্তের\s*গ্রূপ)/i],
    [:education,         /\A(educational\s*qualifications?|education(al)?(\s*background)?|academic\s*qualifications?|qualifications?|শিক্ষাগত\s*যোগ্যতা|শিক্ষা)/i],
    [:profession,        /\A(occupation|profession|job|designation|current\s*job|working\s*as|পেশা|চাকরি|কর্মস্থল)/i],
    [:family_type,       /\A(family\s*type|type\s*of\s*family|পরিবারের\s*ধরন|পরিবারের\s*ধরণ)/i],
    [:family_status,     /\A(family\s*status|financial\s*status|economic\s*status|social\s*status|পারিবারিক\s*অবস্থা|আর্থিক\s*অবস্থা)/i],
    [:present_location,  /\A(present\s*address|current\s*address|present\s*location|current\s*location|currently\s*living|lives?\s*in|বর্তমান\s*ঠিকানা|বর্তমান\s*অবস্থান|বর্তমানে\s*থাকেন)/i],
    [:hometown,          /\A(home\s*town|hometown|home\s*district|permanent\s*address|village|district|গ্রামের\s*বাড়ি|গ্রামের\s*বাড়ি|নিজ\s*জেলা|স্থায়ী\s*ঠিকানা|স্থায়ী\s*ঠিকানা|জেলা)/i],
    [:about,             /\A(about\s*me|about\s*myself|about\s*the\s*(bride|groom)|self\s*description|নিজের\s*সম্পর্কে|আমার\s*সম্পর্কে|নিজ\s*সম্পর্কে)/i],
    [:name,              /\A(full\s*name|name|নাম|পূর্ণ\s*নাম|পাত্রের\s*নাম|পাত্রীর\s*নাম)/i],
    # Labels we recognise only so their value is not read as something else
    [:skip,              /\A(phone|mobile|cell|contact|e-?mail|nid|passport|address|ঠিকানা|মোবাইল|ফোন|যোগাযোগ|ইমেইল|nationality|জাতীয়তা|expectation|partner|প্রত্যাশা)/i]
  ].freeze

  def self.read(path, filename = nil)
    new(path, filename).read
  end

  def initialize(path, filename)
    @path = path
    @ext = File.extname(filename.presence || path).downcase
  end

  def read
    text = normalise(extract_text)
    return { fields: {}, extras: {}, found: 0, text_found: false } if text.strip.length < 20

    values = label_values(text)
    fields = {}
    extras = {}

    fields[:name] = clean_name(values[:name]) if values[:name]
    if (date = parse_date(values[:dob]))
      fields[:date_of_birth] = date.iso8601
    end
    if (ft_in = parse_height(values[:height]))
      fields[:height_ft], fields[:height_inch] = ft_in.map(&:to_s)
    end
    fields[:religion] = map_religion(values[:religion] || text)
    fields[:marital_status] = map_marital(values[:marital_status])
    fields[:gender] = map_gender(values[:gender], text)
    fields[:blood_group] = map_blood(values[:blood_group] || text[/blood\s*group[^\n]{0,15}/i].to_s)
    fields[:highest_education_level] = map_education(values[:education] || text)
    fields[:family_type] = map_family_type(values[:family_type])
    fields[:family_status] = map_family_status(values[:family_status])
    fields[:hometown] = match_district(values[:hometown]) || match_district(@continued[:hometown])
    fields[:present_location] = match_district(values[:present_location]) || match_district(@continued[:present_location])
    fields.compact!

    extras[:profession] = short(values[:profession])
    extras[:education] = short(values[:education], 150)
    extras[:father] = short([values[:father_occupation] || values[:father]].compact.first)
    extras[:mother] = short([values[:mother_occupation] || values[:mother]].compact.first)
    extras[:siblings] = short(values[:siblings])
    extras[:weight] = short(values[:weight], 20)
    extras[:about] = short(values[:about], 1000)
    extras.compact!
    extras.transform_values! { |v| strip_contacts(v) }
    extras.reject! { |_, v| v.blank? }

    { fields: fields, extras: extras, found: fields.size + extras.size, text_found: true }
  rescue StandardError => e
    Rails.logger.error "[biodata] #{e.class}: #{e.message}"
    { fields: {}, extras: {}, found: 0, text_found: false }
  end

  private

  # ── Text from the file ──────────────────────────────────────────────────
  def extract_text
    case @ext
    when '.docx' then docx_text
    when '.pdf'
      text = pdf_text
      text.gsub(/\s/, '').length >= 40 ? text : ocr_pdf
    when '.jpg', '.jpeg', '.png', '.webp', '.gif' then ocr_image(@path)
    else ''
    end
  end

  # A .docx is a zip file; the text is in word/document.xml. Read with Python's built-in zip
  # support (always on Ubuntu), so no extra Ruby library is needed.
  def docx_text
    xml, _err, status = Open3.capture3(
      'python3', '-c',
      'import sys, zipfile; sys.stdout.write(zipfile.ZipFile(sys.argv[1]).read("word/document.xml").decode("utf-8", "replace"))',
      @path
    )
    return '' unless status.success?

    xml = xml.force_encoding('UTF-8')
    # Table rows become "Label : Value" lines
    xml.gsub(%r{</w:p>\s*</w:tc>}, '</w:tc>')
       .gsub(%r{</w:tc>}, ' : ')
       .gsub(%r{</w:tr>}, "\n")
       .gsub(%r{</w:p>|<w:br/>|<w:cr/>}, "\n")
       .gsub(/<w:tab\/>/, ' : ')
       .gsub(/<[^>]+>/, '')
       .then { |t| CGI.unescapeHTML(t) }
  end

  def pdf_text
    out, _err, status = Open3.capture3('pdftotext', '-layout', '-l', MAX_PAGES.to_s, '-enc', 'UTF-8', @path, '-')
    status.success? ? out.force_encoding('UTF-8') : ''
  rescue Errno::ENOENT
    ''
  end

  def ocr_pdf
    Dir.mktmpdir('biodata') do |dir|
      system('convert', '-density', '250', "#{@path}[0-#{MAX_PAGES - 1}]", '-colorspace', 'Gray', File.join(dir, 'page-%d.png'),
             out: File::NULL, err: File::NULL)
      Dir[File.join(dir, 'page-*.png')].sort.map { |page| tesseract(page) }.join("\n")
    end
  end

  def ocr_image(path)
    Dir.mktmpdir('biodata') do |dir|
      prepared = File.join(dir, 'page.png')
      # Grey, larger and sharper: the scanner reads small phone text better this way
      system('convert', path, '-auto-orient', '-colorspace', 'Gray', '-resize', '2000x2000>', '-resize', '200%<',
             '-sharpen', '0x1', prepared, out: File::NULL, err: File::NULL)
      tesseract(File.exist?(prepared) ? prepared : path)
    end
  end

  def tesseract(image)
    out, _err, status = Open3.capture3('tesseract', image, 'stdout', '-l', 'eng+ben', '--psm', '4')
    status.success? ? out.force_encoding('UTF-8') : ''
  rescue Errno::ENOENT
    ''
  end

  # ── Text clean-up ───────────────────────────────────────────────────────
  def normalise(text)
    text.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: ' ')
        .tr(BN_DIGITS, '0123456789')
        .tr('：', ':')
        .gsub(/[‐-―]/, '-')
        .gsub(/[‘’`´]/, "'")
        .gsub(/[“”]/, '"')
        .gsub(/ /, ' ')
        .gsub(/[ \t]+/, ' ')
  end

  # Finds "Label : Value" pairs. A label alone on its line takes the next line as its value.
  # "About me" collects the lines after it until the next label.
  def label_values(text)
    lines = text.split("\n").map { |l| l.strip.sub(/\A(?:[•*\-]\s*|\d{1,2}[.)]\s+)/, '') }.reject(&:blank?)
    values = {}
    @continued = {}
    i = 0
    while i < lines.length
      line = lines[i]
      key, rest = label_for(line)
      if key
        value = rest.to_s.sub(/\A[\s:=\-–|।]+/, '').strip
        if value.blank? && lines[i + 1] && label_for(lines[i + 1]).first.nil?
          value = lines[i + 1].sub(/\A[\s:=\-–|]+/, '').strip
          i += 1
        end
        if key == :about
          more = []
          while lines[i + 1] && label_for(lines[i + 1]).first.nil? && more.size < 12
            more << lines[i + 1]
            i += 1
          end
          value = [value, *more].reject(&:blank?).join(' ')
        end
        if key != :skip && value.present? && !values.key?(key)
          values[key] = value.sub(/[\s:|=\-–]+\z/, '')
          # A value that runs on to the next line (PDF layouts): kept for place names
          nxt = lines[i + 1]
          @continued[key] = "#{value} #{nxt}" if nxt && label_for(nxt).first.nil?
        end
      end
      i += 1
    end
    values
  end

  # PDFs sometimes put stray spaces inside Bangla words ("রক্তে র গ্রুপ"), so labels are
  # looked for with those spaces removed
  def label_for(line)
    compact = compact_bn(line)
    LABELS.each do |key, pattern|
      m = compact.match(pattern)
      next unless m

      rest = line[original_index(line, m[0].length)..].to_s
      # A label must be followed by a separator, spaces or nothing (not more letters of a word)
      next unless rest.blank? || rest.match?(/\A\s*[:=\-–|।]/) || rest.match?(/\A\s{2,}/) || rest.match?(/\A\s*\(/) ||
                  (rest.match?(/\A\s/) && key != :name && key != :father && key != :mother)

      rest = rest.sub(/\A\s*\([^)]*\)/, '') # "Height (ft)" etc.
      return [key, rest]
    end
    [nil, nil]
  end

  def compact_bn(text)
    text.to_s.gsub(/(?<=[ঀ-৿])\s+(?=[ঀ-৿])/, '')
  end

  # Where a position in the compact line falls in the original line
  def original_index(line, compact_len)
    count = 0
    line.each_char.with_index do |ch, i|
      return i if count >= compact_len

      bangla_gap = ch.match?(/\s/) && i.positive? && line[i - 1].match?(/[ঀ-৿]/) &&
                   line[i..].match?(/\A\s+[ঀ-৿]/)
      count += 1 unless bangla_gap
    end
    line.length
  end

  # Removes stray spaces before Bangla vowel signs (a word never starts with one)
  def fix_bn(value)
    value.to_s.gsub(/\s+(?=[ঁ-ঃ়া-্ৗ])/, '')
  end

  def short(value, max = 120)
    return nil if value.blank?

    fix_bn(value).squish.truncate(max)
  end

  # Phone numbers and e-mails never go into the profile
  def strip_contacts(value)
    value.to_s.gsub(/(\+?88)?0?1[3-9]\d{2}[\s-]?\d{6}/, '').gsub(/\S+@\S+/, '').squish
  end

  def clean_name(value)
    name = strip_contacts(fix_bn(value)).sub(/\A(md\.?|mst\.?|mrs?\.?|miss)\s+/i) { |t| t } # keep titles as written
    name = name.split(/\s{2,}|,|\|/).first.to_s.strip
    name.length.between?(2, 60) ? name : nil
  end

  # ── Values ──────────────────────────────────────────────────────────────
  def parse_date(value)
    return nil if value.blank?

    v = value.downcase
    date =
      if (m = v.match(/(\d{1,2})\s*[\/.\-]\s*(\d{1,2})\s*[\/.\-]\s*(\d{4})/))
        safe_date(m[3].to_i, m[2].to_i, m[1].to_i)
      elsif (m = v.match(/(\d{4})\s*[\/.\-]\s*(\d{1,2})\s*[\/.\-]\s*(\d{1,2})/))
        safe_date(m[1].to_i, m[2].to_i, m[3].to_i)
      elsif (m = v.match(/(\d{1,2})(?:st|nd|rd|th)?\s*(?:of\s*)?([a-zঀ-৿]+)[\s,.\-]*(\d{4})/))
        (mon = month_number(m[2])) && safe_date(m[3].to_i, mon, m[1].to_i)
      elsif (m = v.match(/([a-zঀ-৿]+)\s*(\d{1,2})(?:st|nd|rd|th)?[\s,.\-]*(\d{4})/))
        (mon = month_number(m[1])) && safe_date(m[3].to_i, mon, m[2].to_i)
      end
    date if date && date <= Date.current.years_ago(18) && date >= Date.current.years_ago(80)
  end

  def month_number(word)
    MONTHS.each { |k, n| return n if word.start_with?(k) }
    nil
  end

  def safe_date(y, m, d)
    Date.new(y, m, d)
  rescue ArgumentError
    nil
  end

  def parse_height(value)
    return nil if value.blank?

    v = compact_bn(value).downcase
    ft = inch = nil
    if (m = v.match(/(\d)\s*(?:'|’|ft\.?|feet|foot|ফুট)\s*(\d{1,2})?\s*(?:"|''|in\.?|inch(?:es)?|ইঞ্চি)?/))
      ft = m[1].to_i
      inch = m[2].to_i
    elsif (m = v.match(/(\d{3})\s*(?:cm|সেমি)/))
      total = (m[1].to_i / 2.54).round
      ft, inch = total.divmod(12)
    elsif (m = v.match(/\b([4-7])\.(\d{1,2})\b/))
      ft = m[1].to_i
      inch = m[2].to_i
    end
    return nil unless ft && ft.between?(4, 7) && inch.to_i.between?(0, 11)

    [ft, inch.to_i]
  end

  def map_religion(value)
    v = compact_bn(value).downcase
    return 'islam' if v.match?(/islam|muslim|ইসলাম|মুসলিম|মুসলমান/)
    return 'hinduism' if v.match?(/hindu|sanatan|হিন্দু|সনাতন/)
    return 'christianity' if v.match?(/christian|খ্রিস্টান|খ্রিষ্টান/)
    return 'buddhism' if v.match?(/buddh|বৌদ্ধ/)

    nil
  end

  def map_marital(value)
    v = compact_bn(value).downcase
    return nil if v.blank?
    return 'divorced' if v.match?(/divorc|তালাক|ডিভোর্স/)
    return 'widow_or_widower' if v.match?(/widow|বিধবা|বিপত্নীক/)
    return 'separated' if v.match?(/separat|আলাদা/)
    return 'unmarried' if v.match?(/unmarried|single|never\s*married|bachelor|অবিবাহিত|অবিবাহিতা/)

    nil
  end

  def map_gender(value, text)
    v = compact_bn(value).downcase
    text = compact_bn(text)
    return 'female' if v.match?(/female|woman|মহিলা|নারী|মেয়ে|মেয়ে/)
    return 'male' if v.match?(/\bmale\b|\bman\b|পুরুষ|ছেলে/)
    return 'female' if text.match?(/পাত্রী|\bbride\b/i) && !text.match?(/পাত্রের|\bgroom\b/i)
    return 'male' if text.match?(/পাত্রের|পাত্র\s*:|\bgroom\b/i) && !text.match?(/পাত্রী|\bbride\b/i)

    nil
  end

  def map_blood(value)
    v = compact_bn(value).upcase.gsub(/\s+/, '')
    # Bangla: "ও পজিটিভ", "এবি নেগেটিভ"; the scanner may read O as 0
    v = v.sub(/এবি/, 'AB').sub(/এ(?=পজ|নেগ|\+|-)/, 'A').sub(/বি(?=পজ|নেগ|\+|-)/, 'B').sub(/ও(?=পজ|নেগ|\+|-)/, 'O')
         .gsub('পজিটিভ', '+').gsub('নেগেটিভ', '-').gsub(/\(0/, '(O').sub(/\A0(?=[+-])/, 'O')
    m = v.match(/(AB|A|B|O)\(?(\+|-|POSITIVE|NEGATIVE|\+VE|-VE|POS|NEG)\)?/)
    return nil unless m

    sign = m[2].start_with?('+', 'POS') ? '+' : '-'
    "#{m[1]}#{sign}"
  end

  # The highest level mentioned wins
  def map_education(value)
    v = compact_bn(value).downcase
    return 'doctorate' if v.match?(/ph\.?\s*d|doctorate|ডক্টরেট|পিএইচডি/)
    return 'post_graduate' if v.match?(/master|m\.?\s?sc|m\.?\s?a\b|mba|m\.?\s?com|mss|m\.?\s?phil|llm|post\s*grad|মাস্টার্স|স্নাতকোত্তর|এমবিএ/)
    return 'graduate' if v.match?(/bachelor|b\.?\s?sc|bba|b\.?\s?a\b|bss|b\.?\s?com|hons|honours|mbbs|bds|llb|b\.?\s?pharm|graduat|স্নাতক|অনার্স|বিবিএ|বিএসসি|এমবিবিএস/)
    return 'diploma' if v.match?(/diploma|ডিপ্লোমা/)
    return 'intermediate' if v.match?(/hsc|h\.s\.c|intermediate|alim|a[\s-]?level|এইচএসসি|উচ্চ\s*মাধ্যমিক|আলিম/)
    return 'school' if v.match?(/ssc|s\.s\.c|dakhil|o[\s-]?level|school|এসএসসি|মাধ্যমিক|দাখিল/)

    nil
  end

  def map_family_type(value)
    v = compact_bn(value).downcase
    return 'joint_family' if v.match?(/joint|extended|যৌথ/)
    return 'nuclear_family' if v.match?(/nuclear|single|একক/)

    nil
  end

  def map_family_status(value)
    v = compact_bn(value).downcase
    return 'upper_middle_class' if v.match?(/upper\s*middle|উচ্চ\s*মধ্যবিত্ত/)
    return 'middle_Class' if v.match?(/middle|মধ্যবিত্ত/)
    return 'rich/affluent' if v.match?(/rich|affluent|wealthy|upper\s*class|উচ্চবিত্ত|ধনী/)

    nil
  end

  # Finds a Bangladesh district (English or Bangla name) in the text
  def match_district(value)
    return nil if value.blank?

    v = value.downcase.gsub(/[^a-zঀ-৿]+/, ' ')
    bn = compact_bn(value)
    districts.each do |name, key, bangla|
      return name if v.match?(/\b#{Regexp.escape(name.downcase.gsub(/[^a-z]+/, ' ').strip)}\b/) ||
                     (bangla.present? && bn.include?(bangla))
    end
    DISTRICT_ALIASES.each do |alias_name, key|
      next unless v.match?(/\b#{Regexp.escape(alias_name)}\b/)

      found = districts.find { |_, k, _| k == key }
      return found.first if found
    end
    nil
  end

  def districts
    @districts ||= District.pluck(:name).map do |name|
      key = name.to_s.downcase.gsub(/[^a-z]+/, '_').delete_suffix('_')
      bangla = I18n.t("districts.#{key}", locale: :bn, default: '')
      [name, key.delete('_'), bangla]
    end.sort_by { |name, _, _| -name.length }
  end
end
