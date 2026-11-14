# One-off content update (14 Nov 2026), Terms of Use, English and Bangla:
#  2.2 tick box when registering for someone else · 2.3 Confidentiality rewritten ·
#  new 2.7 Kobuls · 3.1 refund exceptions · 3.3 payment through AamarPay · 3.5 first
#  sentence tidied · 13 deactivate/delete wording · 14 laws (no repealed act named) ·
#  typos in 2.6 and 3.6 · 4.3 title "Access by our team".
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/terms_updates_nov14.rb
# Undo:               RAILS_ENV=production bundle exec rails runner script/terms_updates_nov14.rb undo
require 'json'

BACKUP = File.expand_path('~/terms_updates_nov14_backup.json')
SP = '(?:\s|&nbsp;|&#160;| )+'

def phrase(text)
  Regexp.new(text.split(/\s+/).map { |w| Regexp.escape(w) }.join(SP))
end

def section(prefix)
  TermsOfUse.all.detect { |t| t[:title].to_s.strip.start_with?(prefix) }
end

# ---------- whole sections rewritten ----------
NEW_CONTENT = {
  '2.3' => [
    <<~HTML,
      <p>We take privacy very seriously. Your name, phone number and email address are never shown to other members. Your photos are only shown to a member after a 1st Kobul between you has been accepted, and photos cannot be downloaded from the website. You can look for the right bride or groom knowing your information is safe and confidential.</p>
    HTML
    <<~HTML
      <p>আমরা গোপনীয়তাকে অত্যন্ত গুরুত্ব দিই। আপনার নাম, ফোন নম্বর ও ইমেইল ঠিকানা কখনো অন্য সদস্যদের দেখানো হয় না। আপনাদের মধ্যে ১ম কবুল গ্রহণ হওয়ার পরই শুধু সেই সদস্যকে আপনার ছবি দেখানো হয়, এবং ওয়েবসাইট থেকে ছবি ডাউনলোড করা যায় না। আপনার তথ্য নিরাপদ ও গোপন জেনে নিশ্চিন্তে উপযুক্ত পাত্র বা পাত্রী খুঁজতে পারেন।</p>
    HTML
  ],
  '3.1' => [
    "<p>Any fee paid to Bolo Kobul is non-refundable and non-transferable, except as stated in sections 3.5, 3.7 and 3.8.</p>\n",
    "<p>বলো কবুলকে দেওয়া যেকোনো ফি অফেরতযোগ্য ও অহস্তান্তরযোগ্য, তবে ধারা ৩.৫, ৩.৭ ও ৩.৮-এ বলা ক্ষেত্রগুলো ছাড়া।</p>\n"
  ],
  '3.3' => [
    <<~HTML,
      <p>Prices of paid services are stated on the website and include all applicable taxes unless otherwise stated. We may at any time change the price of any paid service. The new rate takes effect if you apply for it after we have posted the details of our new price on the website.</p>
      <p>In the event of suspicious payment activity, we reserve the right to temporarily or permanently suspend payment via your card or mobile account and/or contact you, your bank or any other relevant third party to report such unusual activity and/or obtain additional information.</p>
      <p><strong>Accepted payment methods</strong></p>
      <p>All payments are made through AamarPay, our licensed payment gateway, using:</p>
      <ul>
      <li>bKash</li>
      <li>Nagad</li>
      <li>Visa and Mastercard debit/credit cards</li>
      </ul>
      <p>All transactions are processed securely. Bolo Kobul does not see or store your card or mobile banking details. Payment processing is handled by our licensed payment partner in compliance with Bangladesh Bank regulations.</p>
      <p>For any payment-related queries, please contact us at support@bolokobul.com.</p>
    HTML
    <<~HTML
      <p>পেইড সেবার দাম ওয়েবসাইটে উল্লেখ করা থাকে এবং ভিন্নভাবে উল্লেখ না থাকলে সব প্রযোজ্য কর তাতে অন্তর্ভুক্ত। আমরা যেকোনো সময় যেকোনো পেইড সেবার দাম পরিবর্তন করতে পারি। ওয়েবসাইটে নতুন দাম প্রকাশের পর আবেদন করলে নতুন হার প্রযোজ্য হবে।</p>
      <p>সন্দেহজনক পেমেন্ট কার্যক্রম দেখা গেলে আপনার কার্ড বা মোবাইল অ্যাকাউন্টে পেমেন্ট সাময়িক বা স্থায়ীভাবে স্থগিত করার এবং/অথবা এই অস্বাভাবিক কার্যক্রম জানাতে ও অতিরিক্ত তথ্য পেতে আপনার, আপনার ব্যাংকের বা অন্য কোনো সংশ্লিষ্ট তৃতীয় পক্ষের সঙ্গে যোগাযোগের অধিকার আমরা রাখি।</p>
      <p><strong>গ্রহণযোগ্য পেমেন্ট পদ্ধতি</strong></p>
      <p>সব পেমেন্ট আমাদের লাইসেন্সপ্রাপ্ত পেমেন্ট গেটওয়ে আমারপে (AamarPay)-এর মাধ্যমে করা হয়, যেখানে ব্যবহার করা যায়:</p>
      <ul>
      <li>বিকাশ</li>
      <li>নগদ</li>
      <li>ভিসা ও মাস্টারকার্ড ডেবিট/ক্রেডিট কার্ড</li>
      </ul>
      <p>সব লেনদেন নিরাপদে প্রক্রিয়া করা হয়। বলো কবুল আপনার কার্ড বা মোবাইল ব্যাংকিংয়ের তথ্য দেখে না বা সংরক্ষণ করে না। বাংলাদেশ ব্যাংকের নিয়ম মেনে আমাদের লাইসেন্সপ্রাপ্ত পেমেন্ট সহযোগী পেমেন্ট প্রক্রিয়া করে।</p>
      <p>পেমেন্ট-সংক্রান্ত যেকোনো প্রশ্নে যোগাযোগ করুন: support@bolokobul.com।</p>
    HTML
  ],
  '3.5' => [
    "<p>New members get free butterflies, so a member whose first match succeeds may never need to pay anything. Paid butterflies and services are not refunded. This includes BK+ membership fees and unused BK+ days. Any exception to this policy is made at the sole discretion of the Bolo Kobul management.</p>\n",
    "<p>নতুন সদস্যরা বিনামূল্যে বাটারফ্লাই পান, তাই প্রথম মিলেই সফল হলে কোনো সদস্যকে হয়তো কখনো টাকাই দিতে হবে না। কেনা বাটারফ্লাই ও সেবার টাকা ফেরত দেওয়া হয় না। এর মধ্যে BK+ মেম্বারশিপ ফি এবং অব্যবহৃত BK+ দিনও অন্তর্ভুক্ত। এই নীতির যেকোনো ব্যতিক্রম শুধু বলো কবুল ব্যবস্থাপনার নিজস্ব বিবেচনায় করা হবে।</p>\n"
  ],
  '13.' => [
    <<~HTML,
      <p>Bolo Kobul may issue a warning, temporarily suspend, indefinitely suspend or terminate any User's right to use or access all or any part of the bolokobul.com website including any account thereon, without notice, for any reason in Bolo Kobul's sole discretion, including without limitation Bolo Kobul's belief that such access would violate any applicable law or would be harmful to the interests of, or potentially cause financial loss or legal liability to Bolo Kobul, any of its affiliates or another User. Notice of termination will be delivered to the last email address you provide to us.</p>
      <p>We may deactivate your account if you have not used the service for a consecutive 6-month period.</p>
      <p>You may deactivate or delete your account at any time.</p>
    HTML
    <<~HTML
      <p>বলো কবুল তার একক বিবেচনায়, যেকোনো কারণে, কোনো নোটিশ ছাড়াই যেকোনো ব্যবহারকারীকে সতর্ক করতে, সাময়িক বা অনির্দিষ্টকালের জন্য স্থগিত করতে, অথবা bolokobul.com ওয়েবসাইটের সম্পূর্ণ বা যেকোনো অংশ (এর যেকোনো অ্যাকাউন্টসহ) ব্যবহারের অধিকার বাতিল করতে পারে — এর মধ্যে রয়েছে, তবে এতেই সীমাবদ্ধ নয়, বলো কবুলের এমন বিশ্বাস যে এই ব্যবহার কোনো প্রযোজ্য আইন লঙ্ঘন করবে অথবা বলো কবুল, এর কোনো সহযোগী বা অন্য ব্যবহারকারীর স্বার্থের জন্য ক্ষতিকর হবে বা আর্থিক ক্ষতি বা আইনি দায় সৃষ্টি করতে পারে। বাতিলের নোটিশ আপনার দেওয়া সর্বশেষ ইমেইল ঠিকানায় পাঠানো হবে।</p>
      <p>টানা ৬ মাস সেবা ব্যবহার না করলে আমরা আপনার অ্যাকাউন্ট নিষ্ক্রিয় করতে পারি।</p>
      <p>আপনি যেকোনো সময় নিজের অ্যাকাউন্ট নিষ্ক্রিয় করতে বা মুছে ফেলতে পারেন।</p>
    HTML
  ],
  '14.' => [
    <<~HTML,
      <p>The terms of this contract are exclusively based on and subject to law. You hereby consent to the exclusive jurisdiction and venue of courts will be decided in all disputes arising out of or relating to the use of this website. Use of this website is unauthorised in any jurisdiction that does not give effect to all provisions of these terms and conditions, including without limitation this paragraph.</p>
      <p>This agreement shall be governed by and construed in accordance with the laws of the People's Republic of Bangladesh. Any disputes arising out of or in connection with these Terms shall be subject to the exclusive jurisdiction of the courts of Bangladesh.</p>
      <p>By using bolokobul.com, you agree to comply with all applicable Bangladeshi laws, including but not limited to:</p>
      <ul>
      <li>the laws of Bangladesh on cyber security and digital content, which prohibit sharing false, obscene or defamatory content online</li>
      <li>the Information and Communication Technology (ICT) Act, 2006, governing electronic transactions and digital communications</li>
      <li>data protection: Bolo Kobul is committed to protecting user data in line with Bangladeshi data protection standards as they develop</li>
      <li>personal and family laws, including the Muslim Family Laws Ordinance, 1961 and the Child Marriage Restraint Act, 2017: users are responsible for ensuring their matrimonial intentions comply with them</li>
      <li>the Pornography Control Act, 2012, strictly prohibiting any obscene content on the platform</li>
      </ul>
      <p>Bolo Kobul reserves the right to report any unlawful activity to the relevant Bangladeshi authorities.</p>
    HTML
    <<~HTML
      <p>এই চুক্তির শর্তাবলি সম্পূর্ণভাবে আইনের ওপর ভিত্তি করে এবং আইনের অধীন। এই ওয়েবসাইট ব্যবহার থেকে উদ্ভূত বা এর সঙ্গে সম্পর্কিত সব বিরোধে আদালতের একক এখতিয়ার ও স্থান নির্ধারিত হবে — এতে আপনি এতদ্বারা সম্মতি দিচ্ছেন। যে এখতিয়ারে এই অনুচ্ছেদসহ এই শর্তাবলির সব বিধান কার্যকর হয় না, সেখানে এই ওয়েবসাইটের ব্যবহার অননুমোদিত।</p>
      <p>এই চুক্তি গণপ্রজাতন্ত্রী বাংলাদেশের আইন অনুযায়ী পরিচালিত ও ব্যাখ্যাত হবে। এই শর্তাবলি থেকে উদ্ভূত বা এর সঙ্গে সম্পর্কিত যেকোনো বিরোধ বাংলাদেশের আদালতের একক এখতিয়ারাধীন থাকবে।</p>
      <p>bolokobul.com ব্যবহারের মাধ্যমে আপনি বাংলাদেশের সব প্রযোজ্য আইন মেনে চলতে সম্মত হচ্ছেন, যার মধ্যে রয়েছে, তবে এতেই সীমাবদ্ধ নয়:</p>
      <ul>
      <li>সাইবার নিরাপত্তা ও ডিজিটাল বিষয়বস্তু সংক্রান্ত বাংলাদেশের আইন, যা অনলাইনে মিথ্যা, অশ্লীল বা মানহানিকর বিষয়বস্তু শেয়ার নিষিদ্ধ করে</li>
      <li>তথ্য ও যোগাযোগ প্রযুক্তি (আইসিটি) আইন, ২০০৬, যা ইলেকট্রনিক লেনদেন ও ডিজিটাল যোগাযোগ নিয়ন্ত্রণ করে</li>
      <li>তথ্য সুরক্ষা: বাংলাদেশের বিকাশমান তথ্য সুরক্ষা মানদণ্ড অনুযায়ী ব্যবহারকারীর তথ্য সুরক্ষায় বলো কবুল প্রতিশ্রুতিবদ্ধ</li>
      <li>ব্যক্তিগত ও পারিবারিক আইন, যার মধ্যে মুসলিম পারিবারিক আইন অধ্যাদেশ, ১৯৬১ এবং বাল্যবিবাহ নিরোধ আইন, ২০১৭: বিয়ের উদ্দেশ্য এসব আইনের সঙ্গে সামঞ্জস্যপূর্ণ কি না, তা নিশ্চিত করার দায় ব্যবহারকারীর</li>
      <li>পর্নোগ্রাফি নিয়ন্ত্রণ আইন, ২০১২, যা প্ল্যাটফর্মে যেকোনো অশ্লীল বিষয়বস্তু কঠোরভাবে নিষিদ্ধ করে</li>
      </ul>
      <p>যেকোনো বেআইনি কার্যকলাপ সংশ্লিষ্ট বাংলাদেশি কর্তৃপক্ষকে জানানোর অধিকার বলো কবুল রাখে।</p>
    HTML
  ]
}.freeze

# ---------- small edits inside a section: [section, column, old, new] ----------
EDITS = [
  ['2.2', :content, 'proper consent from the candidate, unless you are the candidate yourself.',
   'proper consent from the candidate, unless you are the candidate yourself. When registering for someone else, you must tick the box confirming their permission, that the details are true and that they are of legal marriage age (21 for men, 18 for women). We keep a record of when you confirmed.'],
  ['2.2', :content_bn, 'প্রোফাইল তৈরির মাধ্যমে আপনি নিশ্চয়তা দিচ্ছেন যে ক্যান্ডিডেটের যথাযথ সম্মতি নেওয়া হয়েছে।',
   'প্রোফাইল তৈরির মাধ্যমে আপনি নিশ্চয়তা দিচ্ছেন যে ক্যান্ডিডেটের যথাযথ সম্মতি নেওয়া হয়েছে। অন্য কারো জন্য নিবন্ধনের সময় টিক দিয়ে নিশ্চিত করতে হবে যে তাঁর অনুমতি আছে, তথ্য সত্য এবং তাঁর বয়স বিয়ের আইনগত বয়সের সমান বা বেশি (ছেলেদের ২১, মেয়েদের ১৮)। আপনি কখন নিশ্চিত করেছেন, তার রেকর্ড আমরা রাখি।'],
  ['2.6', :content, "Users's activites", "Users' activities"],
  ['3.6', :content, 'by logining into their profiles; settings.', 'by logging in and opening Account Settings.']
].freeze

TITLE_EDITS = [
  ['4.3', 'Access by our team', '4.3 আমাদের টিমের প্রবেশাধিকার']
].freeze

NEW_27 = {
  title: '2.7 Kobuls',
  title_bn: '2.7 কবুল',
  content: <<~HTML,
    <p>A 1st Kobul stays open for the number of days shown on the website. The member who receives it is reminded 2 days before it ends. If it is not answered by then, it closes and the sender gets the butterflies back. 2nd Kobuls do not expire.</p>
    <p>You may hide profiles you are not interested in. A hidden profile no longer appears in your recommendations or search, and you can show it again at any time.</p>
  HTML
  content_bn: <<~HTML
    <p>১ম কবুল ওয়েবসাইটে দেখানো নির্দিষ্ট কয়েক দিন খোলা থাকে। শেষ হওয়ার ২ দিন আগে প্রাপককে মনে করিয়ে দেওয়া হয়। এর মধ্যে উত্তর না এলে এটি বন্ধ হয়ে যায় এবং প্রেরক বাটারফ্লাই ফেরত পান। ২য় কবুলের মেয়াদ শেষ হয় না।</p>
    <p>যে প্রোফাইলে আগ্রহী নন, তা লুকিয়ে রাখতে পারেন। লুকানো প্রোফাইল আর আপনার সুপারিশ বা খোঁজার ফলাফলে আসে না, এবং যেকোনো সময় আবার দেখাতে পারেন।</p>
  HTML
}.freeze

# ---------- undo ----------
if ARGV.first == 'undo'
  abort "No backup found at #{BACKUP}" unless File.exist?(BACKUP)
  data = JSON.parse(File.read(BACKUP))
  data['rows'].each do |row|
    TermsOfUse.find(row['id']).update_columns(row['attrs'])
  end
  TermsOfUse.where(id: data['created']).destroy_all
  puts "Undone: Terms of Use restored from #{BACKUP}"
  exit
end
abort "Already done (backup exists at #{BACKUP}). Run with 'undo' first to repeat it." if File.exist?(BACKUP)

backup = { 'rows' => [], 'created' => [] }
remember = lambda do |row|
  next if backup['rows'].any? { |b| b['id'] == row.id }

  backup['rows'] << { 'id' => row.id, 'attrs' => row.attributes.slice('title', 'title_bn', 'content', 'content_bn') }
end
report = []

NEW_CONTENT.each do |prefix, (en, bn)|
  row = section(prefix)
  next report << "  - #{prefix} not found" unless row

  remember.call(row)
  row.update_columns(content: en, content_bn: bn, updated_at: Time.current)
  report << "  ✓ #{row[:title]}: rewritten"
end

EDITS.each do |prefix, col, old_text, new_text|
  row = section(prefix)
  next report << "  - #{prefix} not found" unless row

  html = row[col].to_s
  pattern = phrase(old_text)
  unless html.match?(pattern)
    report << "  - #{prefix} #{col}: text \"#{old_text.truncate(40)}\" not found"
    next
  end
  remember.call(row)
  row.update_columns(col => html.sub(pattern) { new_text }, updated_at: Time.current)
  report << "  ✓ #{row[:title]} (#{col == :content ? 'English' : 'Bangla'}): edited"
end

TITLE_EDITS.each do |prefix, title_en, title_bn|
  row = section(prefix)
  next report << "  - #{prefix} not found" unless row

  remember.call(row)
  row.update_columns(title: "#{prefix} #{title_en}", title_bn: title_bn)
  report << "  ✓ #{prefix}: new title \"#{title_en}\""
end

if section('2.7')
  report << '  - 2.7 already exists, not added again'
else
  after = section('2.6')
  created = TermsOfUse.create!(NEW_27.merge(display_order: after ? after.display_order : 10))
  backup['created'] << created.id
  report << '  ✓ 2.7 Kobuls: added after 2.6'
end

File.write(BACKUP, JSON.pretty_generate(backup))
puts report
puts "Backup: #{BACKUP}"
