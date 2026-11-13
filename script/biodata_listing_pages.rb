# One-off content update (14 Nov 2026): Terms of Use and Privacy Policy for
#  - the Wedding Shopping List business listings (/advertise, ৳1,000 for 1 year)
#  - the optional biodata upload on the Basics step
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/biodata_listing_pages.rb
# Undo:               RAILS_ENV=production bundle exec rails runner script/biodata_listing_pages.rb undo
require 'json'

BACKUP = File.expand_path('~/biodata_listing_pages_backup.json')

TERMS_LIST_EN = <<~'HTML'
<p>Businesses that provide wedding services (for example venues, decorators, photographers, makeup artists and caterers) can apply to be shown on the Wedding Shopping List from the “List your business” page.</p>
<p><strong>(a) Fee and period.</strong> A listing costs ৳1,000 for one year, paid online through AamarPay when applying. The year starts on the day we approve the listing, not on the day of payment.</p>
<p><strong>(b) Review and approval.</strong> Every application is checked by the Bolo Kobul team before it is shown, usually within 2 working days. We may ask for changes, or decline a listing that is incomplete, misleading or not related to weddings. If we cannot approve a listing, the full fee is refunded.</p>
<p><strong>(c) After approval.</strong> Once a listing is approved, the fee is not refundable, including for unused time. The listing does not renew automatically. We send a reminder by email 14 days before it ends, and it stops being shown on the end date unless it is renewed.</p>
<p><strong>(d) The business’s responsibility.</strong> The business confirms that the details, prices and photos it sends are true, belong to it and may be published. It is responsible for its own services, prices, bookings and any agreement it makes with members.</p>
<p><strong>(e) Removal.</strong> We may remove a listing at any time, without a refund, if it breaks these Terms, misleads members, or if we receive serious complaints about the business.</p>
<p><strong>(f) Bolo Kobul’s role.</strong> Bolo Kobul only shows the listing. We do not recommend, guarantee or take part in any deal between a member and a business, and we are not responsible for the services a business provides.</p>
HTML

TERMS_LIST_BN = <<~'HTML'
<p>বিয়ের সেবা দেয় এমন প্রতিষ্ঠান (যেমন ভেন্যু, ডেকোরেটর, ফটোগ্রাফার, মেকআপ আর্টিস্ট ও ক্যাটারার) “ব্যবসা যুক্ত করুন” পেজ থেকে ওয়েডিং শপিং লিস্টে যুক্ত হওয়ার আবেদন করতে পারে।</p>
<p><strong>(ক) ফি ও মেয়াদ।</strong> একটি লিস্টিংয়ের ফি এক বছরের জন্য ৳১,০০০, যা আবেদনের সময় আমারপে-এর মাধ্যমে অনলাইনে পরিশোধ করতে হয়। আমরা লিস্টিং অনুমোদন দেওয়ার দিন থেকে এক বছর শুরু হয়, পেমেন্টের দিন থেকে নয়।</p>
<p><strong>(খ) যাচাই ও অনুমোদন।</strong> প্রতিটি আবেদন দেখানোর আগে বলো কবুল টিম যাচাই করে, সাধারণত ২ কর্মদিবসের মধ্যে। অসম্পূর্ণ, বিভ্রান্তিকর বা বিয়ের সাথে সম্পর্কহীন লিস্টিংয়ের ক্ষেত্রে আমরা পরিবর্তন চাইতে পারি বা আবেদন বাতিল করতে পারি। কোনো লিস্টিং অনুমোদন দিতে না পারলে পুরো ফি ফেরত দেওয়া হয়।</p>
<p><strong>(গ) অনুমোদনের পর।</strong> লিস্টিং অনুমোদিত হওয়ার পর ফি ফেরতযোগ্য নয়, অব্যবহৃত সময়ের জন্যও নয়। লিস্টিং স্বয়ংক্রিয়ভাবে নবায়ন হয় না। মেয়াদ শেষ হওয়ার ১৪ দিন আগে আমরা ইমেইলে মনে করিয়ে দিই, এবং নবায়ন না করলে শেষ তারিখে লিস্টিং দেখানো বন্ধ হয়ে যায়।</p>
<p><strong>(ঘ) প্রতিষ্ঠানের দায়িত্ব।</strong> প্রতিষ্ঠান নিশ্চিত করে যে পাঠানো তথ্য, মূল্য ও ছবি সত্য, তাদের নিজস্ব এবং প্রকাশ করা যাবে। নিজেদের সেবা, মূল্য, বুকিং এবং সদস্যদের সাথে করা যেকোনো চুক্তির দায়িত্ব প্রতিষ্ঠানের।</p>
<p><strong>(ঙ) সরিয়ে ফেলা।</strong> এই শর্তাবলি ভঙ্গ করলে, সদস্যদের বিভ্রান্ত করলে বা প্রতিষ্ঠান সম্পর্কে গুরুতর অভিযোগ পেলে আমরা যেকোনো সময় রিফান্ড ছাড়াই লিস্টিং সরিয়ে ফেলতে পারি।</p>
<p><strong>(চ) বলো কবুলের ভূমিকা।</strong> বলো কবুল শুধু লিস্টিংটি দেখায়। কোনো সদস্য ও প্রতিষ্ঠানের মধ্যে কোনো লেনদেনে আমরা সুপারিশ, নিশ্চয়তা বা অংশগ্রহণ করি না, এবং প্রতিষ্ঠানের দেওয়া সেবার জন্য আমরা দায়ী নই।</p>
HTML

TERMS_BIO_EN = <<~'HTML'
<p>When creating a profile, you may upload your own biodata (a PDF, a Word file or a photo) so that the form can be filled in for you.</p>
<p><strong>(a) Your own biodata only.</strong> Upload only a biodata about yourself, or about the person you are creating the profile for with their permission.</p>
<p><strong>(b) Check before saving.</strong> The details are read automatically and may contain mistakes. You are responsible for checking every filled-in detail before saving it, in the same way as details you type yourself (see section 7).</p>
<p><strong>(c) Keeping the file.</strong> The biodata file is kept privately with your profile, as described in our Privacy Policy, and may be used by the Bolo Kobul team to check your profile.</p>
HTML

TERMS_BIO_BN = <<~'HTML'
<p>প্রোফাইল তৈরির সময় ফর্মটি নিজে থেকে পূরণ করার জন্য আপনি আপনার নিজের বায়োডাটা (PDF, Word ফাইল বা ছবি) আপলোড করতে পারেন।</p>
<p><strong>(ক) শুধু নিজের বায়োডাটা।</strong> শুধু আপনার নিজের বায়োডাটা আপলোড করুন, অথবা যার জন্য প্রোফাইল তৈরি করছেন তার অনুমতি নিয়ে তার বায়োডাটা।</p>
<p><strong>(খ) সংরক্ষণের আগে যাচাই করুন।</strong> তথ্যগুলো স্বয়ংক্রিয়ভাবে পড়া হয় এবং এতে ভুল থাকতে পারে। নিজে লেখা তথ্যের মতোই, সংরক্ষণের আগে প্রতিটি পূরণ হওয়া তথ্য যাচাই করার দায়িত্ব আপনার (ধারা ৭ দেখুন)।</p>
<p><strong>(গ) ফাইল সংরক্ষণ।</strong> বায়োডাটা ফাইলটি আমাদের গোপনীয়তা নীতিতে বর্ণিত উপায়ে আপনার প্রোফাইলের সাথে গোপনে রাখা হয়, এবং আপনার প্রোফাইল যাচাইয়ের জন্য বলো কবুল টিম এটি ব্যবহার করতে পারে।</p>
HTML

PRIV_EN = <<~'HTML'
<p><strong>Your uploaded biodata.</strong> If you upload your biodata when creating a profile, it is read on Bolo Kobul’s own server by automated tools to fill in the form. It is not sent to any outside service. Phone numbers, e-mail addresses and full addresses in it are not copied into your profile. Nothing it fills in is saved until you check it and press Next.</p>
<p>The biodata file is kept privately with your ID document. Only the Bolo Kobul team can open it, for example to check your profile. It is never shown to other members. The details read from it are kept with your profile so that the next steps can offer them to you. The file is removed together with your profile, and you can ask us to remove it sooner by writing to support@bolokobul.com.</p>
<p><strong>Businesses on the Wedding Shopping List.</strong> When a business applies to be listed, we keep the contact person’s name, phone number and e-mail address, which only the Bolo Kobul team can see, and a record of the payment. The business name, category, location, prices, description and photos it sends are shown publicly on the Wedding Shopping List while the listing is active.</p>
HTML

PRIV_BN = <<~'HTML'
<p><strong>আপনার আপলোড করা বায়োডাটা।</strong> প্রোফাইল তৈরির সময় আপনি বায়োডাটা আপলোড করলে ফর্ম পূরণের জন্য বলো কবুলের নিজস্ব সার্ভারে স্বয়ংক্রিয় টুল দিয়ে তা পড়া হয়। এটি বাইরের কোনো সেবায় পাঠানো হয় না। এতে থাকা ফোন নম্বর, ইমেইল ঠিকানা ও পূর্ণ ঠিকানা আপনার প্রোফাইলে কপি করা হয় না। আপনি যাচাই করে “পরবর্তী” না চাপা পর্যন্ত পূরণ হওয়া কোনো তথ্য সংরক্ষণ হয় না।</p>
<p>বায়োডাটা ফাইলটি আপনার আইডি ডকুমেন্টের সাথে গোপনে রাখা হয়। শুধু বলো কবুল টিম এটি খুলতে পারে, যেমন আপনার প্রোফাইল যাচাইয়ের জন্য। অন্য সদস্যদের কখনো দেখানো হয় না। পরের ধাপগুলোতে আপনাকে দেখানোর জন্য এখান থেকে পড়া তথ্য আপনার প্রোফাইলের সাথে রাখা হয়। প্রোফাইলের সাথে ফাইলটিও মুছে যায়, এবং support@bolokobul.com এ লিখে আগেই মুছে ফেলতে বলতে পারেন।</p>
<p><strong>ওয়েডিং শপিং লিস্টের প্রতিষ্ঠান।</strong> কোনো প্রতিষ্ঠান লিস্টিংয়ের জন্য আবেদন করলে আমরা যোগাযোগকারী ব্যক্তির নাম, ফোন নম্বর ও ইমেইল ঠিকানা রাখি, যা শুধু বলো কবুল টিম দেখতে পারে, এবং পেমেন্টের রেকর্ড রাখি। প্রতিষ্ঠানের পাঠানো নাম, ক্যাটাগরি, অবস্থান, মূল্য, বিবরণ ও ছবি লিস্টিং চালু থাকা অবস্থায় ওয়েডিং শপিং লিস্টে সবার জন্য দেখানো হয়।</p>
HTML

OLD_DATE_EN = 'November 12, 2026'
NEW_DATE_EN = 'November 14, 2026'
OLD_DATE_BN = /(১২|12)\s*নভেম্বর,?\s*(২০২৬|2026)/
NEW_DATE_BN = '১৪ নভেম্বর ২০২৬'

# ── Undo ────────────────────────────────────────────────────────────────────
if ARGV.first == 'undo'
  abort "No backup found at #{BACKUP}" unless File.exist?(BACKUP)
  backup = JSON.parse(File.read(BACKUP))
  ActiveRecord::Base.transaction do
    backup['created'].each { |model, id| model.constantize.where(id: id).destroy_all; puts "Removed #{model} #{id}" }
    backup['records'].each do |r|
      rec = r['model'].constantize.find(r['attrs']['id'])
      rec.update_columns(r['attrs'].slice('content', 'content_bn', 'title', 'title_bn'))
      puts "Restored #{r['model']} #{rec.id}"
    end
  end
  puts 'Undo finished.'
  exit
end

# ── Apply ───────────────────────────────────────────────────────────────────
if TermsOfUse.where('title LIKE ?', '%Wedding Shopping%').exists?
  abort 'The new sections already exist - nothing changed (this script was already run).'
end

dated = (TermsOfUse.where('content LIKE ?', "%#{OLD_DATE_EN}%").to_a + PrivacyPolicy.where('content LIKE ?', "%#{OLD_DATE_EN}%").to_a)
backup = { 'records' => dated.map { |r| { 'model' => r.class.name, 'attrs' => r.attributes } }, 'created' => [] }
File.write(BACKUP, JSON.pretty_generate(backup))
puts "Backup saved: #{BACKUP}"

last_terms = TermsOfUse.where('title LIKE ?', '3.7%').first
order = last_terms ? last_terms.display_order.to_i : TermsOfUse.maximum(:display_order).to_i

ActiveRecord::Base.transaction do
  t1 = TermsOfUse.create!(title: '3.8 Wedding Shopping List (business listings)', title_bn: '৩.৮ ওয়েডিং শপিং লিস্ট (প্রতিষ্ঠানের লিস্টিং)',
                          content: TERMS_LIST_EN, content_bn: TERMS_LIST_BN, display_order: order)
  backup['created'] << ['TermsOfUse', t1.id]
  puts "DONE Terms 3.8 Wedding Shopping List added (id #{t1.id})"

  t2 = TermsOfUse.create!(title: '3.9 Uploading your biodata', title_bn: '৩.৯ বায়োডাটা আপলোড',
                          content: TERMS_BIO_EN, content_bn: TERMS_BIO_BN, display_order: order)
  backup['created'] << ['TermsOfUse', t2.id]
  puts "DONE Terms 3.9 Uploading your biodata added (id #{t2.id})"

  priv_order = PrivacyPolicy.where('title LIKE ?', 'Profile visits%').first&.display_order.to_i
  pp = PrivacyPolicy.create!(title: 'Uploaded biodata and business listings', title_bn: 'আপলোড করা বায়োডাটা ও প্রতিষ্ঠানের লিস্টিং',
                             content: PRIV_EN, content_bn: PRIV_BN, display_order: priv_order.positive? ? priv_order : PrivacyPolicy.maximum(:display_order).to_i)
  backup['created'] << ['PrivacyPolicy', pp.id]
  puts "DONE Privacy section added (id #{pp.id})"

  dated.each do |r|
    r.content = r.content.gsub(OLD_DATE_EN, NEW_DATE_EN)
    r.content_bn = r.content_bn.to_s.gsub(OLD_DATE_BN, NEW_DATE_BN) if r.content_bn.present?
    r.save!
    puts "DONE 'Last updated' date set to #{NEW_DATE_EN} in #{r.class.name} #{r.id} (#{r.title})"
  end
end

File.write(BACKUP, JSON.pretty_generate(backup))
puts 'All done. Check /terms_of_uses and /privacy_policies on the site (English and Bangla).'
