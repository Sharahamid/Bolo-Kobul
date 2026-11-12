# One-off content update: adds BK+ to Terms, Privacy, FAQ and About (approved 12 Nov 2026).
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/bk_plus_pages.rb
# Saves a backup first; undo with:  RAILS_ENV=production bundle exec rails runner script/bk_plus_pages_undo.rb
require "json"

TERMS_EN = <<~'HTML'
<p>BK+ is an optional paid membership. Registration, profile creation, searching, viewing profiles and the free butterflies given to new members remain free. BK+ adds extra features on top.</p>
<p><strong>(a) What BK+ includes.</strong> While your BK+ membership is active, you get:</p>
<ul>
<li>a gold BK+ badge beside your Profile ID on profile cards and your profile;</li>
<li>priority in recommendations: among equally good matches, your profile is shown to members before others;</li>
<li>“Who saved you”: the members who added your profile to their Favourites, with their match percentage;</li>
<li>“Who viewed you”: the members who viewed your profile in the last 30 days, when they viewed it, and their match percentage;</li>
<li>bonus butterflies, added to your balance each time you join or add more time. The number depends on the plan.</li>
</ul>
<p><strong>(b) Plans and prices.</strong> BK+ is sold for fixed periods, for example 1 week, 1 month or 1 year. The current plans, prices and bonus butterflies are shown on the BK+ page. We may change plans, prices or features at any time. A change does not affect a plan you have already paid for.</p>
<p><strong>(c) Start, renewal and end.</strong> BK+ starts as soon as your payment is confirmed. It does <strong>not</strong> renew automatically, and you will never be charged without making a new payment yourself. If you buy more time while BK+ is active, the new days are added to your current end date. When BK+ ends, the BK+ features stop. Bonus butterflies already added stay in your balance.</p>
<p><strong>(d) One account.</strong> BK+ belongs to the account that paid for it and covers the profiles on that account. It cannot be transferred, sold or shared.</p>
<p><strong>(e) Fair use.</strong> What you see through “Who saved you” and “Who viewed you” is only for finding a life partner on Bolo Kobul. Section 7 (No Unlawful or Prohibited Use) applies in full. If BK+ is misused, for example to pressure or harass a member, we may end the BK+ membership and the account without a refund.</p>
<p><strong>(f) Refunds.</strong> BK+ fees follow section 3.5 (Refund Policy) and are not refundable, including for unused days. If your payment was taken but BK+ did not start, write to support@bolokobul.com with your order details and we will activate BK+ or return the payment.</p>
HTML

TERMS_BN = <<~'HTML'
<p>BK+ একটি ঐচ্ছিক পেইড মেম্বারশিপ। রেজিস্ট্রেশন, প্রোফাইল তৈরি, খোঁজা, প্রোফাইল দেখা এবং নতুন সদস্যদের দেওয়া ফ্রি বাটারফ্লাই আগের মতোই ফ্রি থাকবে। BK+ এর সাথে কিছু বাড়তি সুবিধা যোগ করে।</p>
<p><strong>(ক) BK+ এ যা পাবেন।</strong> আপনার BK+ মেম্বারশিপ চালু থাকা অবস্থায় পাবেন:</p>
<ul>
<li>প্রোফাইল কার্ড ও প্রোফাইলে আপনার প্রোফাইল আইডির পাশে সোনালি BK+ ব্যাজ;</li>
<li>রেকমেন্ডেশনে অগ্রাধিকার: সমান মানের ম্যাচের মধ্যে আপনার প্রোফাইল অন্যদের আগে দেখানো হবে;</li>
<li>“কে আপনাকে সেভ করেছে”: যেসব সদস্য আপনার প্রোফাইল তাদের ফেভারিটে রেখেছেন, তাদের ম্যাচ শতাংশসহ;</li>
<li>“কে আপনাকে দেখেছে”: গত ৩০ দিনে যেসব সদস্য আপনার প্রোফাইল দেখেছেন, কবে দেখেছেন এবং তাদের ম্যাচ শতাংশ;</li>
<li>বোনাস বাটারফ্লাই, যা প্রতিবার যোগ দেওয়া বা সময় বাড়ানোর সময় আপনার ব্যালেন্সে যোগ হয়। সংখ্যাটি প্ল্যানের ওপর নির্ভর করে।</li>
</ul>
<p><strong>(খ) প্ল্যান ও মূল্য।</strong> BK+ নির্দিষ্ট মেয়াদের জন্য বিক্রি হয়, যেমন ১ সপ্তাহ, ১ মাস বা ১ বছর। বর্তমান প্ল্যান, মূল্য ও বোনাস বাটারফ্লাই BK+ পেজে দেখানো থাকে। আমরা যেকোনো সময় প্ল্যান, মূল্য বা সুবিধা পরিবর্তন করতে পারি। আগে থেকে পরিশোধ করা প্ল্যানে কোনো পরিবর্তনের প্রভাব পড়বে না।</p>
<p><strong>(গ) শুরু, নবায়ন ও শেষ।</strong> পেমেন্ট নিশ্চিত হওয়ার সাথে সাথেই BK+ শুরু হয়। এটি <strong>স্বয়ংক্রিয়ভাবে নবায়ন হয় না</strong>, এবং আপনি নিজে নতুন পেমেন্ট না করলে কখনো টাকা কাটা হবে না। BK+ চালু থাকা অবস্থায় আরও সময় কিনলে নতুন দিনগুলো বর্তমান মেয়াদ শেষের তারিখের পরে যোগ হবে। BK+ শেষ হলে এর সুবিধাগুলো বন্ধ হয়ে যাবে। আগে যোগ হওয়া বোনাস বাটারফ্লাই আপনার ব্যালেন্সেই থাকবে।</p>
<p><strong>(ঘ) একটি অ্যাকাউন্ট।</strong> যে অ্যাকাউন্ট থেকে BK+ কেনা হয়েছে, BK+ সেই অ্যাকাউন্টের এবং সেই অ্যাকাউন্টের প্রোফাইলগুলোর জন্য প্রযোজ্য। এটি হস্তান্তর, বিক্রি বা শেয়ার করা যাবে না।</p>
<p><strong>(ঙ) সঠিক ব্যবহার।</strong> “কে আপনাকে সেভ করেছে” এবং “কে আপনাকে দেখেছে” অংশে যা দেখবেন, তা শুধু বলো কবুলে জীবনসঙ্গী খোঁজার জন্য। ধারা ৭ (বেআইনি বা নিষিদ্ধ ব্যবহার নয়) সম্পূর্ণভাবে প্রযোজ্য। BK+ এর অপব্যবহার হলে, যেমন কোনো সদস্যকে চাপ দেওয়া বা হয়রানি করা, আমরা কোনো রিফান্ড ছাড়াই BK+ মেম্বারশিপ ও অ্যাকাউন্ট বন্ধ করতে পারি।</p>
<p><strong>(চ) রিফান্ড।</strong> BK+ এর ফি ধারা ৩.৫ (রিফান্ড নীতি) অনুযায়ী ফেরতযোগ্য নয়, অব্যবহৃত দিনের জন্যও নয়। যদি পেমেন্ট কাটা হয় কিন্তু BK+ চালু না হয়, অর্ডারের বিবরণসহ support@bolokobul.com এ লিখুন; আমরা BK+ চালু করে দেব অথবা টাকা ফেরত দেব।</p>
HTML

PRIV_EN = <<~'HTML'
<p><strong>Profile visits (“Who viewed you”).</strong> When you are logged in and open another member’s profile, we record that your profile viewed theirs, how many times, and when you last viewed it. We keep these records for 90 days, then delete them automatically. All members can see how many people viewed their profile. Only members with an active BK+ membership can see who viewed them in the last 30 days, when, and the match percentage. They see your Profile ID and the details your profile already shows them. They never see your name, phone number or email address. Members you have blocked, or who have blocked you, are never shown. Visits between profiles on the same account are not recorded.</p>
<p><strong>Favourites (“Who saved you”).</strong> When you add a profile to your Favourites, that member can see the number of people who saved them. If they have BK+, they can also see which profiles saved them, with the match percentage.</p>
<p><strong>Payments.</strong> When you buy butterflies, BK+ or an Assisted Service, we keep a record of the order: the item, the amount, the date and the payment reference. Your card and mobile banking details are entered on AamarPay’s secure page. We never see or store your full card number, PIN or password.</p>
<p><strong>Notifications on your phone or computer.</strong> If you allow notifications, your browser or the Bolo Kobul app gives us a notification address for that device. We use it only to send Bolo Kobul alerts, such as new Kobuls and messages. You can turn notifications off at any time in your browser or phone settings. When a device stops accepting notifications, we delete its address.</p>
HTML

PRIV_BN = <<~'HTML'
<p><strong>প্রোফাইল ভিজিট (“কে আপনাকে দেখেছে”)।</strong> লগইন থাকা অবস্থায় আপনি অন্য কোনো সদস্যের প্রোফাইল খুললে আমরা সংরক্ষণ করি যে আপনার প্রোফাইল তাদের প্রোফাইল দেখেছে, কতবার দেখেছে এবং শেষ কবে দেখেছে। এই তথ্য ৯০ দিন রাখা হয়, তারপর স্বয়ংক্রিয়ভাবে মুছে ফেলা হয়। সব সদস্য দেখতে পারেন কতজন তাদের প্রোফাইল দেখেছেন। শুধু চালু BK+ মেম্বারশিপ থাকা সদস্যরা দেখতে পারেন গত ৩০ দিনে কে তাদের দেখেছেন, কবে এবং ম্যাচ শতাংশ। তারা আপনার প্রোফাইল আইডি এবং আপনার প্রোফাইল তাদের যা আগে থেকেই দেখায় সেটুকু দেখেন। আপনার নাম, ফোন নম্বর বা ইমেইল ঠিকানা তারা কখনো দেখেন না। আপনি যাদের ব্লক করেছেন বা যারা আপনাকে ব্লক করেছেন, তাদের কখনো দেখানো হয় না। একই অ্যাকাউন্টের প্রোফাইলগুলোর মধ্যে ভিজিট সংরক্ষণ করা হয় না।</p>
<p><strong>ফেভারিট (“কে আপনাকে সেভ করেছে”)।</strong> আপনি কোনো প্রোফাইল ফেভারিটে রাখলে সেই সদস্য দেখতে পান কতজন তাকে সেভ করেছেন। তার BK+ থাকলে তিনি ম্যাচ শতাংশসহ দেখতে পান কোন প্রোফাইলগুলো তাকে সেভ করেছে।</p>
<p><strong>পেমেন্ট।</strong> আপনি বাটারফ্লাই, BK+ বা অ্যাসিস্টেড সার্ভিস কিনলে আমরা অর্ডারের রেকর্ড রাখি: কী কিনেছেন, পরিমাণ, তারিখ ও পেমেন্ট রেফারেন্স। আপনার কার্ড ও মোবাইল ব্যাংকিংয়ের তথ্য আমারপে-এর নিরাপদ পেজে দেওয়া হয়। আপনার পূর্ণ কার্ড নম্বর, পিন বা পাসওয়ার্ড আমরা কখনো দেখি না বা সংরক্ষণ করি না।</p>
<p><strong>ফোন বা কম্পিউটারে নোটিফিকেশন।</strong> আপনি নোটিফিকেশনের অনুমতি দিলে আপনার ব্রাউজার বা বলো কবুল অ্যাপ ওই ডিভাইসের একটি নোটিফিকেশন ঠিকানা আমাদের দেয়। আমরা এটি শুধু বলো কবুলের অ্যালার্ট পাঠাতে ব্যবহার করি, যেমন নতুন কবুল ও মেসেজ। ব্রাউজার বা ফোনের সেটিংস থেকে যেকোনো সময় নোটিফিকেশন বন্ধ করতে পারেন। কোনো ডিভাইস নোটিফিকেশন নেওয়া বন্ধ করলে আমরা তার ঠিকানা মুছে ফেলি।</p>
HTML

FAQ_EN = <<~'HTML'
<p><strong>What is BK+?</strong> BK+ is an optional paid membership that helps your profile stand out and shows you who is interested in you. You do not need BK+ to find a match: Kobuls and chat work the same for everyone.</p>
<p><strong>What do I get with BK+?</strong> A gold BK+ badge beside your Profile ID; priority in recommendations (among equally good matches, your profile is shown first); “Who saved you” (members who added you to Favourites, with match %); “Who viewed you” (members who viewed your profile in the last 30 days, and when); and bonus butterflies each time you join or add time.</p>
<p><strong>How much does BK+ cost?</strong> Plans are sold for fixed periods, for example 1 week, 1 month or 1 year. The current prices and bonus butterflies are shown on the BK+ page.</p>
<p><strong>How do I join BK+?</strong> Open BK+ from the menu, choose a plan and pay through AamarPay (bKash, Nagad or Visa/Mastercard). BK+ starts as soon as the payment is confirmed.</p>
<p><strong>Does BK+ renew automatically?</strong> No. You are never charged without making a new payment yourself.</p>
<p><strong>Can I add more time?</strong> Yes. Choose “Add more days”. The new days are added after your current end date, so you lose nothing.</p>
<p><strong>What happens when BK+ ends?</strong> The badge, priority, Who saved you and Who viewed you stop. Your bonus butterflies stay in your balance. Your profile, Kobuls and chats are not affected.</p>
<p><strong>Who can see that I viewed their profile?</strong> Only members with active BK+, and only for the last 30 days. They see your Profile ID and the details your profile already shows them, never your name or contact details. Members you have blocked never see you.</p>
<p><strong>Can I view profiles without appearing in “Who viewed you”?</strong> Not at the moment. If you do not want a particular member to see you, you can block them.</p>
<p><strong>Is BK+ refundable?</strong> No. BK+ fees, including unused days, are not refundable (see Terms 3.5). If you paid but BK+ did not start, write to support@bolokobul.com with your order details and we will sort it out.</p>
HTML

FAQ_BN = <<~'HTML'
<p><strong>BK+ কী?</strong> BK+ একটি ঐচ্ছিক পেইড মেম্বারশিপ, যা আপনার প্রোফাইলকে আলাদা করে তোলে এবং দেখায় কারা আপনার প্রতি আগ্রহী। ম্যাচ খুঁজে পেতে BK+ লাগে না: কবুল ও চ্যাট সবার জন্য একইভাবে কাজ করে।</p>
<p><strong>BK+ এ কী কী পাব?</strong> প্রোফাইল আইডির পাশে সোনালি BK+ ব্যাজ; রেকমেন্ডেশনে অগ্রাধিকার (সমান মানের ম্যাচের মধ্যে আপনার প্রোফাইল আগে দেখানো হয়); “কে আপনাকে সেভ করেছে” (যারা আপনাকে ফেভারিটে রেখেছেন, ম্যাচ শতাংশসহ); “কে আপনাকে দেখেছে” (গত ৩০ দিনে যারা আপনার প্রোফাইল দেখেছেন, এবং কবে); আর প্রতিবার যোগ দেওয়া বা সময় বাড়ানোর সময় বোনাস বাটারফ্লাই।</p>
<p><strong>BK+ এর খরচ কত?</strong> প্ল্যানগুলো নির্দিষ্ট মেয়াদের জন্য, যেমন ১ সপ্তাহ, ১ মাস বা ১ বছর। বর্তমান মূল্য ও বোনাস বাটারফ্লাই BK+ পেজে দেখানো থাকে।</p>
<p><strong>কীভাবে BK+ এ যোগ দেব?</strong> মেনু থেকে BK+ খুলুন, একটি প্ল্যান বেছে নিন এবং আমারপে (বিকাশ, নগদ বা ভিসা/মাস্টারকার্ড) দিয়ে পেমেন্ট করুন। পেমেন্ট নিশ্চিত হলেই BK+ চালু হয়।</p>
<p><strong>BK+ কি স্বয়ংক্রিয়ভাবে নবায়ন হয়?</strong> না। আপনি নিজে নতুন পেমেন্ট না করলে কখনো টাকা কাটা হয় না।</p>
<p><strong>আরও সময় যোগ করা যাবে?</strong> হ্যাঁ। “আরও দিন যোগ করুন” বেছে নিন। নতুন দিনগুলো বর্তমান মেয়াদ শেষের পরে যোগ হয়, তাই কোনো দিন নষ্ট হয় না।</p>
<p><strong>BK+ শেষ হলে কী হয়?</strong> ব্যাজ, অগ্রাধিকার, “কে আপনাকে সেভ করেছে” ও “কে আপনাকে দেখেছে” বন্ধ হয়ে যায়। বোনাস বাটারফ্লাই আপনার ব্যালেন্সেই থাকে। আপনার প্রোফাইল, কবুল ও চ্যাটে কোনো প্রভাব পড়ে না।</p>
<p><strong>কারা দেখতে পারেন যে আমি তাদের প্রোফাইল দেখেছি?</strong> শুধু চালু BK+ থাকা সদস্যরা, এবং শুধু গত ৩০ দিনের জন্য। তারা আপনার প্রোফাইল আইডি এবং আপনার প্রোফাইল তাদের যা আগে থেকেই দেখায় সেটুকু দেখেন; আপনার নাম বা যোগাযোগের তথ্য কখনো নয়। আপনি যাদের ব্লক করেছেন, তারা আপনাকে কখনো দেখেন না।</p>
<p><strong>“কে আপনাকে দেখেছে”-তে না এসে কি প্রোফাইল দেখা যায়?</strong> আপাতত না। নির্দিষ্ট কোনো সদস্য আপনাকে না দেখুক চাইলে তাকে ব্লক করতে পারেন।</p>
<p><strong>BK+ কি রিফান্ডযোগ্য?</strong> না। অব্যবহৃত দিনসহ BK+ এর ফি ফেরতযোগ্য নয় (শর্তাবলি ৩.৫ দেখুন)। পেমেন্ট করার পরও BK+ চালু না হলে অর্ডারের বিবরণসহ support@bolokobul.com এ লিখুন, আমরা সমাধান করে দেব।</p>
HTML

PAID_EN = "<p>Registration, profile creation, searching and viewing profiles are free. New members get free butterflies to send and accept Kobuls, and chat opens free once both Kobuls are accepted. Optional paid services: more butterflies (from Orders); BK+ membership (badge, priority in recommendations, Who saved you, Who viewed you and bonus butterflies); Assisted Services, including Get Verified and help from an experienced matchmaker. Text (SMS) alerts can be turned on and are paid with butterflies.</p>"
VISIT_EN = "Yes, with BK+. Every member can see how many people viewed their profile. BK+ members can also see who viewed it in the last 30 days, and when. See “BK+ Membership” below."
ABOUT_EN = "</br>\r\n</br><strong>BK+ Membership</strong> - an optional upgrade with a gold badge, priority in recommendations, “Who viewed you” and “Who saved you”, and bonus butterflies"

if TermsOfUse.where("title LIKE ?", "%BK+%").exists? || Faq.where("title LIKE ?", "%BK+%").exists?
  abort "BK+ sections already exist - nothing changed (this script was already run)."
end

touched = [[TermsOfUse, 5], [TermsOfUse, 43], [TermsOfUse, 38], [Faq, 25], [Faq, 16], [About, 1]]
backup = { "records" => touched.map { |m, id| { "model" => m.name, "attrs" => m.find(id).attributes } }, "created" => [] }
file = File.expand_path("~/bk_plus_pages_backup.json")
File.write(file, JSON.pretty_generate(backup))
puts "Backup saved: #{file}"

report = []
note = ->(ok, msg) { report << "#{ok ? 'DONE ' : 'SKIP '} #{msg}" }
insert_before_last_p = ->(html, text) {
  i = html.to_s.rindex("</p>")
  i ? html.dup.insert(i, text) : html.to_s + text
}

ActiveRecord::Base.transaction do
  # 1A new Terms section
  t = TermsOfUse.create!(title: "3.7 BK+ Membership", title_bn: "৩.৭ BK+ মেম্বারশিপ", content: TERMS_EN, content_bn: TERMS_BN, display_order: 15)
  backup["created"] << ["TermsOfUse", t.id]; note.(true, "Terms 3.7 BK+ Membership added (id #{t.id})")

  # 1B Terms 2.1
  r = TermsOfUse.find(5)
  ok = r.content.include?("such as assisted services,")
  r.content = r.content.sub("such as assisted services,", "such as assisted services, extra butterflies and BK+ membership,") if ok
  note.(ok, "Terms 2.1 English")
  bn_ok = r.content_bn.to_s.include?("অ্যাসিস্টেড সার্ভিস")
  r.content_bn = r.content_bn.sub("অ্যাসিস্টেড সার্ভিস", "অ্যাসিস্টেড সার্ভিস, অতিরিক্ত বাটারফ্লাই ও BK+ মেম্বারশিপ") if bn_ok
  note.(bn_ok, "Terms 2.1 Bangla")
  r.save!

  # 1C Terms 3.5 refund
  r = TermsOfUse.find(43)
  r.content = insert_before_last_p.(r.content, " This includes BK+ membership fees and unused BK+ days.")
  r.content_bn = insert_before_last_p.(r.content_bn, " এর মধ্যে BK+ মেম্বারশিপ ফি এবং অব্যবহৃত BK+ দিনও অন্তর্ভুক্ত।") if r.content_bn.present?
  r.save!; note.(true, "Terms 3.5 refund sentence (English#{r.content_bn.present? ? ' and Bangla' : ''})")

  # 1D Terms 12.1 date
  r = TermsOfUse.find(38)
  ok = r.content.include?("October 01, 2026")
  r.content = r.content.sub("October 01, 2026", "November 12, 2026") if ok
  note.(ok, "Terms 12.1 date (English)")
  bn = r.content_bn.to_s
  bn_new = bn.sub(/(০?১|01)\s*অক্টোবর,?\s*(২০২৬|2026)/, "১২ নভেম্বর ২০২৬")
  note.(bn_new != bn, "Terms 12.1 date (Bangla)#{bn_new == bn ? ' - date not found: ' + bn[/.{0,60}(২০২৬|2026).{0,20}/m].to_s.inspect : ''}")
  r.content_bn = bn_new
  r.save!

  # 2A new Privacy section
  pp = PrivacyPolicy.create!(title: "Profile visits, Favourites, payments and notifications", title_bn: "প্রোফাইল ভিজিট, ফেভারিট, পেমেন্ট ও নোটিফিকেশন", content: PRIV_EN, content_bn: PRIV_BN, display_order: 6)
  backup["created"] << ["PrivacyPolicy", pp.id]; note.(true, "Privacy section added (id #{pp.id})")

  # 3A new FAQ group
  f = Faq.create!(title: "BK+ Membership", title_bn: "BK+ মেম্বারশিপ", content: FAQ_EN, content_bn: FAQ_BN, display_order: 13)
  backup["created"] << ["Faq", f.id]; note.(true, "FAQ BK+ Membership added (id #{f.id})")

  # 3B FAQ 25 visitors answer
  r = Faq.find(25)
  q = r.content.index("visited my Profile?")
  n = q && r.content.index(/\bNo\./, q)
  ok = n && (n - q) < 1500
  r.content = r.content[0...n] + VISIT_EN + r.content[(n + 3)..] if ok
  r.save!; note.(ok, "FAQ visitors answer (English)")

  # 3C FAQ 16 paid services answer
  r = Faq.find(16)
  a = r.content.index("What are the paid services?")
  b = a && r.content.index("</h2>", a)
  c = r.content.index("How do I choose a matchmaker?")
  c = c && r.content.rindex("<h2", c)
  ok = a && b && c && c > b
  r.content = r.content[0...(b + 5)] + "\r\n\r\n" + PAID_EN + "\r\n\r\n" + r.content[c..] if ok
  r.save!; note.(ok, "FAQ paid services answer (English)")

  # 4A About line
  r = About.find(1)
  k = "we offer human support when you need it"
  ok = r.content.include?(k)
  r.content = r.content.sub(k, k + ABOUT_EN) if ok
  r.save!; note.(ok, "About BK+ line (English)")
end

File.write(file, JSON.pretty_generate(backup))
puts report
puts "Bangla text of the FAQ answers and About line was left as it is (it needs a matching Bangla edit)."
