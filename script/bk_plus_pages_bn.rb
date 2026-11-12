# One-off: the Bangla halves of the BK+ edits (Terms 2.1, FAQ visitors answer, FAQ paid services, About line).
# Run: RAILS_ENV=production bundle exec rails runner script/bk_plus_pages_bn.rb
# Undo: BACKUP=~/bk_plus_pages_bn_backup.json RAILS_ENV=production bundle exec rails runner script/bk_plus_pages_undo.rb
require "json"

PAID_BN = "<p>রেজিস্ট্রেশন, প্রোফাইল তৈরি, খোঁজা ও প্রোফাইল দেখা ফ্রি। নতুন সদস্যরা কবুল পাঠানো ও গ্রহণের জন্য ফ্রি বাটারফ্লাই পান, আর দুটি কবুলই গৃহীত হলে চ্যাট ফ্রিতে খুলে যায়। ঐচ্ছিক পেইড সেবা: আরও বাটারফ্লাই (অর্ডার থেকে); BK+ মেম্বারশিপ (ব্যাজ, রেকমেন্ডেশনে অগ্রাধিকার, কে আপনাকে সেভ করেছে, কে আপনাকে দেখেছে এবং বোনাস বাটারফ্লাই); অ্যাসিস্টেড সার্ভিস, যার মধ্যে আছে Get Verified এবং অভিজ্ঞ ঘটকের সহায়তা। টেক্সট (SMS) অ্যালার্ট চালু করা যায়, যার খরচ বাটারফ্লাই দিয়ে দিতে হয়।</p>"
VISIT_BN = "হ্যাঁ, BK+ এর মাধ্যমে। সব সদস্য দেখতে পারেন কতজন তাদের প্রোফাইল দেখেছেন। BK+ সদস্যরা গত ৩০ দিনে কে দেখেছেন এবং কবে, তাও দেখতে পারেন। নিচে “BK+ মেম্বারশিপ” দেখুন।"
ABOUT_BN = "</br>\r\n</br><strong>BK+ মেম্বারশিপ</strong> - একটি ঐচ্ছিক আপগ্রেড: সোনালি ব্যাজ, রেকমেন্ডেশনে অগ্রাধিকার, “কে আপনাকে দেখেছে” ও “কে আপনাকে সেভ করেছে”, এবং বোনাস বাটারফ্লাই"

touched = [[TermsOfUse, 5], [Faq, 25], [Faq, 16], [About, 1]]
file = File.expand_path("~/bk_plus_pages_bn_backup.json")
File.write(file, JSON.pretty_generate({ "records" => touched.map { |m, id| { "model" => m.name, "attrs" => m.find(id).attributes } }, "created" => [] }))
puts "Backup saved: #{file}"
report = []
note = ->(ok, msg) { report << "#{ok ? 'DONE ' : 'SKIP '} #{msg}" }

ActiveRecord::Base.transaction do
  r = TermsOfUse.find(5)
  k = "সহায়তা সেবার মতো অতিরিক্ত সুবিধা"
  ok = r.content_bn.to_s.include?(k) && !r.content_bn.include?("BK+")
  r.update!(content_bn: r.content_bn.sub(k, "সহায়তা সেবা, অতিরিক্ত বাটারফ্লাই ও BK+ মেম্বারশিপের মতো অতিরিক্ত সুবিধা")) if ok
  note.(ok, "Terms 2.1 Bangla")

  r = Faq.find(25)
  t = r.content_bn.to_s
  q = t.index("কারা আমার প্রোফাইল দেখেছেন")
  n = q && t.index("না।", q)
  ok = n && (n - q) < 1500
  r.update!(content_bn: t[0...n] + VISIT_BN + t[(n + 3)..]) if ok
  note.(ok, "FAQ visitors answer Bangla")

  r = Faq.find(16)
  t = r.content_bn.to_s
  a = t.index("পেইড সেবাগুলো কী কী?")
  b = a && t.index("</h2>", a)
  c = b && t.index("<h2", b)
  ok = a && b && c && (b - a) < 400
  r.update!(content_bn: t[0...(b + 5)] + "\r\n\r\n" + PAID_BN + "\r\n\r\n" + t[c..]) if ok
  note.(ok, "FAQ paid services answer Bangla#{ok ? '' : " (a=#{a.inspect} b=#{b.inspect} c=#{c.inspect})"}")

  r = About.find(1)
  t = r.content_bn.to_s
  k = "প্রয়োজনে আমরা মানুষের সরাসরি সহায়তা দিই"
  ok = t.include?(k) && !t.include?("BK+")
  r.update!(content_bn: t.sub(k, k + ABOUT_BN)) if ok
  note.(ok, "About BK+ line Bangla")
end
puts report
