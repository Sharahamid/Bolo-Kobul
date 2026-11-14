# One-off content update (14 Nov 2026), English and Bangla:
#  Privacy Policy – what we collect (no card numbers, no banner/newsletter distributors,
#    consent record), who we share with (no marketing by associates, no outside
#    matchmakers), how long we keep information (the real 30-day deletion).
#  About Us – "What we do" with the real two-Kobul steps; "send Kobuls"; "Why us" table;
#    BK+ 20 recommendations a day.
#  Safety Tips – 1st and 2nd Kobul, "Learn more about them", phone-verified + reports
#    reviewed within 24 hours, proper bullet lists, money lines merged.
#  Contact – points businesses to "List your business"; head office address.
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/pages_updates_nov14.rb
# Undo:               RAILS_ENV=production bundle exec rails runner script/pages_updates_nov14.rb undo
require 'json'

BACKUP = File.expand_path('~/pages_updates_nov14_backup.json')
SP = '(?:\s|&nbsp;|&#160;| )+'

def phrase(text)
  Regexp.new(text.split(/\s+/).map { |w| Regexp.escape(w) }.join(SP))
end

def ul(items)
  "<ul>\n#{items.map { |i| "<li>#{i}</li>" }.join("\n")}\n</ul>"
end

def ps(*paras)
  paras.map { |p| p.start_with?('<') ? p : "<p>#{p}</p>" }.join("\n")
end

# ===================== PRIVACY POLICY (whole sections) =====================
PRIVACY = {
  'What information' => [
    ps('When you use our website, we receive and collect certain information. The information that we receive and collect depends on what you do when you visit our website, but may not be limited to e-mail address, name, date of birth, educational qualifications, a user-specified password, mailing address, mobile number or occupational details.',
       '<p><strong>Automatically Collected Information</strong></p>',
       'Some information is automatically received and sometimes collected from you when you visit our website. We receive and collect the name of the domain and host from which you access the Internet; the Internet protocol (IP) address of the computer you are using; the browser software you use and your operating system; the date and time you access our site; and the internet address of the website from which you linked directly to our site. We use this information to monitor the usage of our site. Besides, when we send emails to you, we may be able to identify information about your email address, such as whether you can read graphic-rich HTML emails. All of the information we automatically capture provides us with the ability to enhance the usability of our website and to determine aggregate information about our user base and usage patterns.',
       '<p><strong>Information Collected via Cookies</strong></p>',
       'We use cookies to enhance the browsing experience on our website. Cookies are small files placed on your device that help us provide our services. Only our own website reads the information in our cookies. We do not control the use of cookies by third parties.',
       'The information captured makes it possible for us:',
       ul(['to speed navigation;', 'to provide you with appropriate match suggestions;', "to remember information that you gave to us so you don't have to re-enter it each time you visit our website;", 'to monitor the effectiveness of our emails;', 'to monitor the total number of visitors and pages viewed.']),
       'Cookies are also used to keep you logged in. Card and mobile banking payments are made on the secure pages of our payment partner, AamarPay; we never see or store your card number or its expiry date.',
       'Most people do not know that cookies are being placed on their computers when they visit our website or most websites because browsers are typically set to accept cookies. You can choose to have your browser warn you every time a cookie is being sent to you or you can turn off cookie placement. If you refuse cookies, you will not be able to use our website properly. Also, by not using cookies, your overall Internet browsing experience will be affected.',
       '<p><strong>Information You Actively Submit to Our Website</strong></p>',
       'Our website is designed to be accessed by registered users. Except for a few pages, which are designed to describe how our website works, most of the pages require that you be logged in our website using a registered account. To open an account, you will need to choose a password. In doing so, we require that you provide us with all of the following Personal Information: your name, email address, and phone number. We do not collect any information which can be used to collect money from you (such as credit card, bank account, etc). If you create a Profile for someone (including yourself), you require that you provide additional personal details which are needed to find matches for that Profile.',
       "When someone registers a profile for another person, we store the date and time they confirmed the candidate's permission.",
       'The user information we collect depends on the context of your interactions with us and the website, the choices you make and the products and features you use. The user information is used for authentication and account access. When the user accesses our website, data relating to device ID, log files, geographic location, and device information/specification are also collected automatically.',
       'We may use your personal information for analysis of data, usage trends, and to evaluate and improve our website, marketing research, and prevention of frauds. In our efforts to continually improve our product and service offerings, we collect and analyse demographic and profile data about our users\' activity on our website. We identify and use your IP address to help diagnose problems with our server, and to administer our website. Your IP address is also used to help identify you and to gather broad demographic information.',
       'We also use session cookies to keep payment sessions with our payment partner AamarPay (bKash, Nagad and cards) secure. These sessions are temporary and expire once your transaction is complete.'),
    ps('আপনি আমাদের ওয়েবসাইট ব্যবহার করলে আমরা কিছু তথ্য পাই ও সংগ্রহ করি। কী তথ্য পাব ও সংগ্রহ করব তা নির্ভর করে ওয়েবসাইটে আপনি কী করছেন তার ওপর, তবে এর মধ্যে থাকতে পারে ইমেইল ঠিকানা, নাম, জন্মতারিখ, শিক্ষাগত যোগ্যতা, আপনার দেওয়া পাসওয়ার্ড, ডাক ঠিকানা, মোবাইল নম্বর বা পেশাগত তথ্য।',
       '<p><strong>স্বয়ংক্রিয়ভাবে সংগৃহীত তথ্য</strong></p>',
       'আপনি ওয়েবসাইটে এলে কিছু তথ্য স্বয়ংক্রিয়ভাবে আমাদের কাছে আসে এবং কখনো কখনো সংগ্রহ করা হয়। আপনি যে ডোমেইন ও হোস্ট থেকে ইন্টারনেট ব্যবহার করছেন তার নাম; আপনার ব্যবহৃত কম্পিউটারের আইপি (IP) ঠিকানা; আপনার ব্রাউজার সফটওয়্যার ও অপারেটিং সিস্টেম; আমাদের সাইটে আসার তারিখ ও সময়; এবং যে ওয়েবসাইট থেকে সরাসরি আমাদের সাইটে এসেছেন তার ঠিকানা আমরা পাই ও সংগ্রহ করি। সাইটের ব্যবহার পর্যবেক্ষণে আমরা এই তথ্য ব্যবহার করি। এছাড়া আপনাকে ইমেইল পাঠালে আপনার ইমেইল ঠিকানা সম্পর্কে কিছু তথ্য জানতে পারি, যেমন আপনি ছবিসমৃদ্ধ HTML ইমেইল পড়তে পারেন কি না। স্বয়ংক্রিয়ভাবে সংগৃহীত সব তথ্য আমাদের ওয়েবসাইটকে আরও সহজে ব্যবহারযোগ্য করতে এবং ব্যবহারকারী ও ব্যবহারের ধরন সম্পর্কে সামগ্রিক ধারণা পেতে সাহায্য করে।',
       '<p><strong>কুকির মাধ্যমে সংগৃহীত তথ্য</strong></p>',
       'আমাদের ওয়েবসাইট ব্যবহারের অভিজ্ঞতা উন্নত করতে আমরা কুকি ব্যবহার করি। কুকি হলো আপনার ডিভাইসে রাখা ছোট ফাইল, যা আমাদের সেবা দিতে সাহায্য করে। আমাদের কুকির তথ্য শুধু আমাদের নিজস্ব ওয়েবসাইটই পড়ে। তৃতীয় পক্ষের কুকি ব্যবহার আমরা নিয়ন্ত্রণ করি না।',
       'সংগৃহীত তথ্যের মাধ্যমে আমরা যা করতে পারি:',
       ul(['দ্রুত পাতা ঘোরা;', 'আপনাকে উপযুক্ত ম্যাচের সুপারিশ দেওয়া;', 'আপনার দেওয়া তথ্য মনে রাখা, যাতে প্রতিবার ওয়েবসাইটে এসে আবার দিতে না হয়;', 'আমাদের ইমেইলের কার্যকারিতা পর্যবেক্ষণ;', 'মোট দর্শক ও দেখা পাতার সংখ্যা পর্যবেক্ষণ।']),
       'আপনাকে লগ ইন রাখতেও কুকি ব্যবহার করা হয়। কার্ড ও মোবাইল ব্যাংকিংয়ের পেমেন্ট আমাদের পেমেন্ট সহযোগী আমারপে (AamarPay)-এর নিরাপদ পাতায় করা হয়; আপনার কার্ড নম্বর বা কার্ডের মেয়াদ আমরা কখনো দেখি না বা সংরক্ষণ করি না।',
       'বেশিরভাগ মানুষ জানেন না যে আমাদের বা অধিকাংশ ওয়েবসাইটে গেলে তাদের কম্পিউটারে কুকি রাখা হয়, কারণ ব্রাউজার সাধারণত কুকি গ্রহণ করার জন্যই সেট করা থাকে। চাইলে প্রতিবার কুকি পাঠানোর সময় ব্রাউজার যেন আপনাকে সতর্ক করে সে ব্যবস্থা করতে পারেন, অথবা কুকি পুরোপুরি বন্ধ করতে পারেন। কুকি প্রত্যাখ্যান করলে আমাদের ওয়েবসাইট ঠিকমতো ব্যবহার করতে পারবেন না, এবং আপনার সামগ্রিক ইন্টারনেট ব্যবহারের অভিজ্ঞতাও প্রভাবিত হবে।',
       '<p><strong>ওয়েবসাইটে আপনি নিজে যে তথ্য দেন</strong></p>',
       'আমাদের ওয়েবসাইট নিবন্ধিত ব্যবহারকারীদের জন্য তৈরি। ওয়েবসাইট কীভাবে কাজ করে তা বোঝানোর কয়েকটি পাতা ছাড়া বেশিরভাগ পাতা দেখতে নিবন্ধিত অ্যাকাউন্টে লগইন থাকতে হয়। অ্যাকাউন্ট খুলতে একটি পাসওয়ার্ড বেছে নিতে হবে। এ সময় আপনাকে নিচের সব ব্যক্তিগত তথ্য দিতে হবে: আপনার নাম, ইমেইল ঠিকানা ও ফোন নম্বর। আপনার কাছ থেকে টাকা নেওয়ার কাজে লাগতে পারে এমন কোনো তথ্য (যেমন ক্রেডিট কার্ড, ব্যাংক অ্যাকাউন্ট ইত্যাদি) আমরা সংগ্রহ করি না। কারও জন্য (নিজেসহ) প্রোফাইল তৈরি করলে সেই প্রোফাইলের জন্য মিল খুঁজতে প্রয়োজনীয় অতিরিক্ত ব্যক্তিগত তথ্য দিতে হবে।',
       'কেউ অন্য কারো জন্য প্রোফাইল নিবন্ধন করলে, পাত্র/পাত্রীর অনুমতি নিশ্চিত করার তারিখ ও সময় আমরা সংরক্ষণ করি।',
       'আমরা কী তথ্য সংগ্রহ করি তা নির্ভর করে আমাদের ও ওয়েবসাইটের সঙ্গে আপনার যোগাযোগের প্রেক্ষাপট, আপনার সিদ্ধান্ত এবং আপনার ব্যবহৃত পণ্য ও সুবিধার ওপর। ব্যবহারকারীর তথ্য পরিচয় যাচাই ও অ্যাকাউন্টে প্রবেশের জন্য ব্যবহৃত হয়। ব্যবহারকারী ওয়েবসাইটে এলে ডিভাইস আইডি, লগ ফাইল, ভৌগোলিক অবস্থান ও ডিভাইসের তথ্য/বৈশিষ্ট্যও স্বয়ংক্রিয়ভাবে সংগ্রহ করা হয়।',
       'তথ্য বিশ্লেষণ, ব্যবহারের প্রবণতা বোঝা, ওয়েবসাইটের মূল্যায়ন ও উন্নয়ন, বাজার গবেষণা এবং প্রতারণা প্রতিরোধে আমরা আপনার ব্যক্তিগত তথ্য ব্যবহার করতে পারি। আমাদের পণ্য ও সেবা ক্রমাগত উন্নত করার প্রচেষ্টায় আমরা ওয়েবসাইটে ব্যবহারকারীদের কার্যকলাপের জনমিতিক ও প্রোফাইল তথ্য সংগ্রহ ও বিশ্লেষণ করি। সার্ভারের সমস্যা নির্ণয় ও ওয়েবসাইট পরিচালনায় আমরা আপনার আইপি ঠিকানা শনাক্ত ও ব্যবহার করি। আপনাকে শনাক্ত করতে এবং বিস্তৃত জনমিতিক তথ্য সংগ্রহেও আপনার আইপি ঠিকানা ব্যবহৃত হয়।',
       'আমাদের পেমেন্ট সহযোগী আমারপে (বিকাশ, নগদ ও কার্ড)-এর সঙ্গে পেমেন্ট সেশন নিরাপদ রাখতেও আমরা সেশন কুকি ব্যবহার করি। এই সেশনগুলো সাময়িক এবং লেনদেন শেষ হলেই মেয়াদ শেষ হয়ে যায়।')
  ],
  'With whom' => [
    ps('We do not sell your personal information, and we do not share it with other companies for their own marketing. Any information you give us is held with the utmost care and security. We are also bound to cooperate fully should a situation arise where we are required by law or legal process to provide information about a customer.',
       'Where required or permitted by law, information may be provided to others, such as regulators and law enforcement agencies or to protect the rights, property or personal safety of Bolo Kobul, other users or the general public.',
       'If you choose an Assisted Service with a matchmaker, the matchmaker our team assigns to you sees only the profile details needed to help you.',
       'From time to time, we may consider corporate transactions such as a merger, acquisition, reorganization, asset sale, or similar. In these instances, we may transfer or allow access to information to enable the assessment and undertaking of that transaction. If we buy or sell any business or assets, personal information may be transferred to third parties involved in the transaction.',
       'Our website links to other websites that may collect personally identifiable information about you. We are not responsible for the privacy policy or the contents of those linked websites.'),
    ps('আমরা আপনার ব্যক্তিগত তথ্য বিক্রি করি না, এবং অন্য প্রতিষ্ঠানের নিজস্ব বিপণনের জন্য শেয়ারও করি না। আপনার দেওয়া যেকোনো তথ্য সর্বোচ্চ যত্ন ও নিরাপত্তার সঙ্গে রাখা হয়। আইন বা আইনি প্রক্রিয়া অনুযায়ী কোনো গ্রাহকের তথ্য দেওয়ার প্রয়োজন হলে আমরা পূর্ণ সহযোগিতা করতে বাধ্য।',
       'আইনে প্রয়োজন বা অনুমোদিত হলে নিয়ন্ত্রক সংস্থা ও আইনশৃঙ্খলা রক্ষাকারী বাহিনীর মতো অন্যদের তথ্য দেওয়া হতে পারে, অথবা বলো কবুল, অন্য ব্যবহারকারী বা জনসাধারণের অধিকার, সম্পত্তি বা ব্যক্তিগত নিরাপত্তা রক্ষায় তথ্য দেওয়া হতে পারে।',
       'আপনি ঘটকসহ কোনো সহায়তা সেবা নিলে, আমাদের টিমের নির্ধারিত ঘটক আপনাকে সাহায্য করতে যতটুকু প্রয়োজন শুধু ততটুকু প্রোফাইল তথ্য দেখেন।',
       'সময়ে সময়ে আমরা একীভূতকরণ, অধিগ্রহণ, পুনর্গঠন, সম্পদ বিক্রি বা এ ধরনের কোনো প্রাতিষ্ঠানিক লেনদেন বিবেচনা করতে পারি। এসব ক্ষেত্রে লেনদেনটির মূল্যায়ন ও সম্পাদনের জন্য আমরা তথ্য হস্তান্তর করতে বা তথ্য দেখার সুযোগ দিতে পারি। কোনো ব্যবসা বা সম্পদ কেনাবেচা করলে ব্যক্তিগত তথ্য লেনদেনে যুক্ত তৃতীয় পক্ষের কাছে হস্তান্তর হতে পারে।',
       'আমাদের ওয়েবসাইটে অন্য ওয়েবসাইটের লিংক আছে, যেগুলো আপনার সম্পর্কে শনাক্তযোগ্য ব্যক্তিগত তথ্য সংগ্রহ করতে পারে। সেসব ওয়েবসাইটের গোপনীয়তা নীতি বা বিষয়বস্তুর জন্য আমরা দায়ী নই।')
  ],
  'How long' => [
    ps('We keep your information while your account is open, so that we can provide our services to you.',
       'When you delete your account (Account Settings → Delete Account), it is hidden from other members straight away, and erased permanently after 30 days. You can cancel the deletion within those 30 days. When it is erased, your profiles, photos, documents, chats, Kobuls, favourites and notifications are removed.',
       'Some records are kept longer where the law or our accounts require it: payment records are kept without your name, phone number or email address, and safety reports may be kept to protect other members and to deal with disputes or legal requests.',
       'You can also ask us to delete your account and data at any time by writing to support@bolokobul.com. We will process your request within 30 days.'),
    ps('আপনার অ্যাকাউন্ট চালু থাকা পর্যন্ত আপনাকে সেবা দেওয়ার জন্য আমরা আপনার তথ্য রাখি।',
       'আপনি অ্যাকাউন্ট মুছে ফেললে (অ্যাকাউন্ট সেটিংস → অ্যাকাউন্ট মুছুন) এটি সঙ্গে সঙ্গে অন্য সদস্যদের কাছ থেকে লুকানো হয় এবং ৩০ দিন পর স্থায়ীভাবে মুছে ফেলা হয়। এই ৩০ দিনের মধ্যে মুছে ফেলা বাতিল করতে পারবেন। মুছে ফেলার সময় আপনার প্রোফাইল, ছবি, ডকুমেন্ট, চ্যাট, কবুল, ফেভারিট ও নোটিফিকেশন মুছে যায়।',
       'আইন বা আমাদের হিসাবের প্রয়োজনে কিছু রেকর্ড বেশি সময় রাখা হয়: পেমেন্টের রেকর্ড আপনার নাম, ফোন নম্বর বা ইমেইল ছাড়া রাখা হয়, এবং অন্য সদস্যদের সুরক্ষা ও বিরোধ বা আইনি অনুরোধ নিষ্পত্তির জন্য নিরাপত্তা-সংক্রান্ত অভিযোগ রাখা হতে পারে।',
       'যেকোনো সময় support@bolokobul.com এ লিখেও আপনার অ্যাকাউন্ট ও তথ্য মুছে ফেলার অনুরোধ করতে পারেন। আমরা ৩০ দিনের মধ্যে আপনার অনুরোধ কার্যকর করব।')
  ]
}.freeze

# ===================== ABOUT US =====================
ABOUT_WHAT_WE_DO = [
  ps("Marriage shouldn't mean added pressure, stress, or uncertainty. Bolo Kobul simplifies the journey of finding the right partner while keeping your personal data safe and secure.",
     'Our Kobul system makes the matchmaking process simple, respectful, and effective:',
     ul(['<strong>1st Kobul (Show interest)</strong> – Browse profiles and send a 1st Kobul to someone you are interested in. When they accept, you both see each other\'s full profile, including photos, education, family and lifestyle.',
         '<strong>2nd Kobul (Start chatting)</strong> – Ready to talk? Send a 2nd Kobul. When it is accepted, chat opens, so you can take the conversation forward at your own pace in a safe and private space. Phone numbers stay hidden.']),
     'Additional features we offer:',
     ul(['<strong>Partner Preferences</strong> – Set detailed criteria including age, height, education, profession, hometown, and lifestyle habits to find the most compatible match',
         '<strong>Verified Profiles</strong> – Our credential validation service helps ensure members are who they say they are, giving you peace of mind',
         '<strong>Privacy Controls</strong> – You decide what information is visible and to whom at every step of your journey',
         '<strong>Assisted Services</strong> – From biodata support to offline matchmakers and relationship advisors, we offer human support when you need it',
         '<strong>BK+ Membership</strong> – an optional upgrade with a gold badge, priority in recommendations, 20 recommendations a day, “Who viewed you” and “Who saved you”, and bonus butterflies'])),
  ps('বিয়ে মানেই বাড়তি চাপ, দুশ্চিন্তা বা অনিশ্চয়তা হওয়া উচিত নয়। বলো কবুল সঠিক জীবনসঙ্গী খোঁজার পথটি সহজ করে, আর আপনার ব্যক্তিগত তথ্য রাখে নিরাপদ ও সুরক্ষিত।',
     'আমাদের কবুল পদ্ধতি জীবনসঙ্গী খোঁজার প্রক্রিয়াকে সহজ, সম্মানজনক ও কার্যকর করে তোলে:',
     ul(['<strong>১ম কবুল (আগ্রহ প্রকাশ)</strong> – প্রোফাইল দেখুন এবং যাঁর প্রতি আগ্রহী তাঁকে ১ম কবুল পাঠান। তিনি গ্রহণ করলে দুজনেই একে অপরের ছবি, শিক্ষা, পরিবার ও জীবনযাপনসহ পূর্ণ প্রোফাইল দেখতে পাবেন।',
         '<strong>২য় কবুল (চ্যাট শুরু)</strong> – কথা বলতে প্রস্তুত? ২য় কবুল পাঠান। গ্রহণ হলে চ্যাট চালু হয়, আর নিরাপদ ও গোপনীয় পরিবেশে নিজের গতিতে কথোপকথন এগিয়ে নিতে পারেন। ফোন নম্বর গোপন থাকে।']),
     'আমাদের আরও যেসব সুবিধা রয়েছে:',
     ul(['<strong>জীবনসঙ্গীর পছন্দ</strong> – বয়স, উচ্চতা, শিক্ষা, পেশা, নিজ জেলা ও জীবনযাপনের অভ্যাসসহ বিস্তারিত শর্ত ঠিক করে সবচেয়ে মানানসই জীবনসঙ্গী খুঁজুন',
         '<strong>যাচাইকৃত প্রোফাইল</strong> – আমাদের পরিচয় যাচাই সেবা নিশ্চিত করতে সাহায্য করে যে সদস্যরা সত্যিই তারা যা বলছেন, যাতে আপনি নিশ্চিন্ত থাকতে পারেন',
         '<strong>গোপনীয়তার নিয়ন্ত্রণ</strong> – যাত্রার প্রতিটি ধাপে কোন তথ্য কে দেখবে, তা আপনিই ঠিক করেন',
         '<strong>সহায়তা সেবা</strong> – বায়োডাটা তৈরিতে সাহায্য থেকে শুরু করে ঘটক ও সম্পর্ক বিষয়ক পরামর্শদাতা পর্যন্ত — প্রয়োজনে আমরা মানুষের সরাসরি সহায়তা দিই',
         '<strong>BK+ মেম্বারশিপ</strong> – একটি ঐচ্ছিক আপগ্রেড: সোনালি ব্যাজ, রেকমেন্ডেশনে অগ্রাধিকার, দিনে ২০টি সুপারিশ, “কে আপনাকে দেখেছে” ও “কে আপনাকে সেভ করেছে”, এবং বোনাস বাটারফ্লাই']))
].freeze

# [content_type contains, column, [old texts (any)], new text]
ABOUT_EDITS = [
  ['Who we are', :content, ['send “butterflies” to show interest', 'send "butterflies" to show interest'], 'send a “Kobul” to show interest'],
  ['Who we are', :content_bn, ['আগ্রহ জানাতে “বাটারফ্লাই” পাঠান', 'আগ্রহ জানাতে "বাটারফ্লাই" পাঠান'], 'আগ্রহ জানাতে “কবুল” পাঠান'],
  ['How we do', :content, ['send butterflies'], 'send Kobuls'],
  ['How we do', :content_bn, ['বাটারফ্লাই পাঠাতে'], 'কবুল পাঠাতে'],
  ['Why us', :content, ['Find matches instantly'], 'Daily recommendations'],
  ['Why us', :content, ['Screened profiles + Block feature', 'Every member is phone-verified; profiles with a checked ID show a Verified badge'], 'Report &amp; Block on every profile'],
  ['Why us', :content, ['Thousands of verified profiles', 'Members across Bangladesh and abroad'], 'Phone-verified members, ID-verified badge'],
  ['Why us', :content_bn, ['সঙ্গে সঙ্গে ম্যাচ খুঁজুন'], 'প্রতিদিনের সুপারিশ'],
  ['Why us', :content_bn, ['যাচাই করা প্রোফাইল + ব্লক সুবিধা', 'প্রত্যেক সদস্যের ফোন নম্বর যাচাই করা; আইডি যাচাই হওয়া প্রোফাইলে ভেরিফায়েড ব্যাজ'], 'প্রতিটি প্রোফাইলে রিপোর্ট ও ব্লক'],
  ['Why us', :content_bn, ['হাজারো যাচাইকৃত প্রোফাইল', 'বাংলাদেশ ও প্রবাসের সদস্য'], 'ফোন যাচাই করা সদস্য, আইডি যাচাইয়ের ব্যাজ']
].freeze

# ===================== SAFETY TIPS (whole sections, by English title) =====================
SAFETY = {
  'Getting to Know' => [
    ps("Bolo Kobul's Kobul system is designed with your safety in mind. Chat only opens after both 1st and 2nd Kobuls are accepted. This means no stranger can message you out of the blue.",
       ul(['Initial Conversation', 'First Meeting', 'Uncomfortable experience → Report or Block']),
       "Take your time to get to know someone before sharing personal details. Use Bolo Kobul's secure messaging system for all early conversations. Never share your NID number, bank details, home address, or workplace details until you have established significant trust."),
    ps('বলো কবুলের কবুল পদ্ধতি আপনার নিরাপত্তার কথা ভেবেই তৈরি। ১ম ও ২য় দুটি কবুলই গ্রহণ হওয়ার পরই কেবল চ্যাট চালু হয়। তাই কোনো অপরিচিত ব্যক্তি হঠাৎ করে আপনাকে বার্তা পাঠাতে পারে না।',
       ul(['প্রাথমিক কথোপকথন', 'প্রথম সাক্ষাৎ', 'অস্বস্তিকর অভিজ্ঞতা → অভিযোগ বা ব্লক']),
       'ব্যক্তিগত তথ্য জানানোর আগে কাউকে ভালোভাবে চিনতে সময় নিন। শুরুর দিকের সব কথোপকথনের জন্য বলো কবুলের নিরাপদ মেসেজিং ব্যবস্থা ব্যবহার করুন। যথেষ্ট আস্থা তৈরি না হওয়া পর্যন্ত কখনো আপনার এনআইডি নম্বর, ব্যাংকের তথ্য, বাসার ঠিকানা বা কর্মস্থলের তথ্য জানাবেন না।')
  ],
  'Initial Conversation' => [
    ps('Take your time to know the other person at your own pace. It is better not to be in a hurry as it is a life-changing, lifelong decision.',
       '<p><strong>Ice breaking</strong></p>',
       ul(['Use our chatting system in order to protect your identity', 'Do not disclose your personal details such as bank particulars, home address, contact address and number, your name or any other identifiable information']),
       '<p><strong>Exchanging phone numbers</strong></p>',
       ul(['Hold on to this until you have established a reasonable level of trust']),
       '<p><strong>Learn more about them</strong></p>',
       ul(['It’s smart to learn more about the member using various social networking sites and government resources.', 'If you still want to know more, feel free to use third party background verification services']),
       '<p><strong>Be your own boss</strong></p>',
       ul(["Don't let any member pressurize you into anything. Block or Report or simply inform us in such case. Every profile on Bolo Kobul has a Block option (three-dot menu on the profile card). Use it immediately if someone makes you uncomfortable — they will no longer be able to view your profile or contact you."]),
       '<p><strong>Watch for scams (common in Bangladesh)</strong></p>',
       ul(["Be alert to anyone who quickly asks for money, claims to be abroad and needs financial help, sends generic messages that don't reference your profile, or pressures you to move communication off the platform"]),
       '<p><strong>We’ll be there for you</strong></p>',
       ul(['For anything at all, you can contact us.'])),
    ps('নিজের গতিতে সময় নিয়ে অপরজনকে জানুন। এটি জীবন বদলে দেওয়া, সারা জীবনের সিদ্ধান্ত, তাই তাড়াহুড়ো না করাই ভালো।',
       '<p><strong>জড়তা কাটানো</strong></p>',
       ul(['নিজের পরিচয় সুরক্ষিত রাখতে আমাদের চ্যাট ব্যবস্থা ব্যবহার করুন', 'ব্যাংকের তথ্য, বাসার ঠিকানা, যোগাযোগের ঠিকানা ও নম্বর, নিজের নাম বা পরিচয় প্রকাশ করে এমন কোনো ব্যক্তিগত তথ্য জানাবেন না']),
       '<p><strong>ফোন নম্বর বিনিময়</strong></p>',
       ul(['যথেষ্ট আস্থা তৈরি না হওয়া পর্যন্ত অপেক্ষা করুন']),
       '<p><strong>তাঁর সম্পর্কে আরও জানুন</strong></p>',
       ul(['বিভিন্ন সামাজিক যোগাযোগমাধ্যম ও সরকারি সূত্র থেকে সদস্য সম্পর্কে আরও জেনে নেওয়া বুদ্ধিমানের কাজ।', 'আরও জানতে চাইলে নির্দ্বিধায় তৃতীয় পক্ষের পটভূমি যাচাই সেবা নিতে পারেন']),
       '<p><strong>সিদ্ধান্ত আপনার</strong></p>',
       ul(['কোনো সদস্যকে আপনার ওপর কোনো কিছুর জন্য চাপ দিতে দেবেন না। এমন হলে ব্লক করুন, অভিযোগ করুন অথবা আমাদের জানান। বলো কবুলের প্রতিটি প্রোফাইলে ব্লক অপশন আছে (প্রোফাইল কার্ডের তিন-বিন্দু মেনুতে)। কেউ অস্বস্তি তৈরি করলে সঙ্গে সঙ্গে এটি ব্যবহার করুন — তিনি আর আপনার প্রোফাইল দেখতে বা আপনার সঙ্গে যোগাযোগ করতে পারবেন না।']),
       '<p><strong>প্রতারণা থেকে সাবধান (বাংলাদেশে প্রায়ই ঘটে)</strong></p>',
       ul(['কেউ খুব তাড়াতাড়ি টাকা চাইলে, বিদেশে থাকেন দাবি করে আর্থিক সাহায্য চাইলে, আপনার প্রোফাইলের সঙ্গে সম্পর্কহীন একই ধাঁচের বার্তা পাঠালে, অথবা প্ল্যাটফর্মের বাইরে কথা বলতে চাপ দিলে সতর্ক থাকুন']),
       '<p><strong>আমরা আছি আপনার পাশে</strong></p>',
       ul(['যেকোনো বিষয়ে আপনি আমাদের সঙ্গে যোগাযোগ করতে পারেন।']))
  ],
  'First Meeting' => [
    ps('It’s natural to have butterflies in your stomach. Here are a few tips to plan your venue and travel:',
       ul(['Pick a public place', 'Take your own ride', 'Bring a friend or relative along and ask the other member to do the same. In case you are meeting alone, inform a friend or family member of your plans']),
       'For anything at all, you can contact us.'),
    ps('প্রথম দেখার আগে মনে প্রজাপতি উড়বে, এটাই স্বাভাবিক। দেখা করার জায়গা ও যাতায়াত পরিকল্পনার কিছু পরামর্শ:',
       ul(['জনসমাগমপূর্ণ জায়গা বেছে নিন', 'নিজের যানবাহনে যাতায়াত করুন', 'একজন বন্ধু বা আত্মীয়কে সঙ্গে নিন এবং অপর সদস্যকেও একই কাজ করতে বলুন। একা দেখা করলে আপনার পরিকল্পনার কথা কোনো বন্ধু বা পরিবারের সদস্যকে জানিয়ে রাখুন']),
       'যেকোনো বিষয়ে আপনি আমাদের সঙ্গে যোগাযোগ করতে পারেন।')
  ],
  'Unpleasant' => [
    ps('We do our best to ensure you get the best possible experience while finding your life partner through Bolo Kobul. Every member is phone-verified and every report is reviewed within 24 hours, and your matches are suggested as per your preferences. However, if you still have any unpleasant or uncomfortable experience or face any of the following:',
       ul(['Someone sending harassing or offensive messages', 'Someone sharing obscene photos', 'Someone being abusive', 'Someone sharing misleading information', 'Someone asking for money', 'Someone having multiple profiles']),
       'Report or Block the person.',
       'For anything at all, you can contact us.'),
    ps('বলো কবুলের মাধ্যমে জীবনসঙ্গী খোঁজার সময় আপনি যেন সবচেয়ে ভালো অভিজ্ঞতা পান, সেজন্য আমরা সর্বোচ্চ চেষ্টা করি। প্রত্যেক সদস্যের ফোন নম্বর যাচাই করা হয় এবং প্রতিটি অভিযোগ ২৪ ঘণ্টার মধ্যে দেখা হয়, আর আপনার পছন্দ অনুযায়ী ম্যাচ সুপারিশ করা হয়। তবু কোনো অপ্রীতিকর বা অস্বস্তিকর অভিজ্ঞতা হলে অথবা নিচের কোনোটির মুখোমুখি হলে:',
       ul(['কেউ হয়রানিমূলক বা আপত্তিকর বার্তা পাঠালে', 'কেউ অশ্লীল ছবি পাঠালে', 'কেউ অপমানজনক আচরণ করলে', 'কেউ বিভ্রান্তিকর তথ্য দিলে', 'কেউ টাকা চাইলে', 'কারও একাধিক প্রোফাইল থাকলে']),
       'তার বিরুদ্ধে অভিযোগ করুন বা তাকে ব্লক করুন।',
       'যেকোনো বিষয়ে আপনি আমাদের সঙ্গে যোগাযোগ করতে পারেন।')
  ],
  'Scamster' => [
    ps('No genuine person would ask you for money, so DO NOT give money to anyone you meet through the platform. Even if the person claims to be in an emergency, report it to us immediately.',
       'You might be dealing with a scamster if that person:',
       ul(['Asks you to take your conversation outside Bolo Kobul at the very beginning',
           'Asks for money or mobile banking transfers, often early on or claiming an emergency',
           'Disappears mysteriously from the website, and then reappears again',
           'Asks for your address under the guise of sending gifts or flowers',
           'Pretends to be serious about you unexpectedly fast',
           'Provides inconsistent descriptions about self',
           'Avoids introducing you to his/her family and friends',
           'Refuses video calls or in-person meetings',
           'Profile photos look too professional or stolen from social media',
           'Claims to be overseas Bangladeshi in urgent need',
           'Pushes to move to WhatsApp or Telegram quickly',
           'Story keeps changing on key details like job or family'])),
    ps('কোনো সত্যিকারের মানুষ আপনার কাছে টাকা চাইবেন না, তাই প্ল্যাটফর্মের মাধ্যমে পরিচয় হওয়া কাউকে কখনোই টাকা দেবেন না। কেউ জরুরি অবস্থার কথা বললেও সঙ্গে সঙ্গে আমাদের জানান।',
       'কেউ নিচের কাজগুলো করলে আপনি হয়তো একজন প্রতারকের পাল্লায় পড়েছেন:',
       ul(['একেবারে শুরুতেই বলো কবুলের বাইরে কথা বলতে বলেন',
           'টাকা বা মোবাইল ব্যাংকিংয়ে টাকা পাঠাতে বলেন, প্রায়ই শুরুর দিকে বা জরুরি অবস্থার কথা বলে',
           'রহস্যজনকভাবে ওয়েবসাইট থেকে উধাও হয়ে আবার ফিরে আসেন',
           'উপহার বা ফুল পাঠানোর অজুহাতে আপনার ঠিকানা চান',
           'অপ্রত্যাশিত দ্রুততায় আপনার ব্যাপারে গুরুতর হওয়ার ভান করেন',
           'নিজের সম্পর্কে অসংগতিপূর্ণ বর্ণনা দেন',
           'নিজের পরিবার ও বন্ধুদের সঙ্গে আপনার পরিচয় করিয়ে দিতে চান না',
           'ভিডিও কল বা সামনাসামনি দেখা করতে রাজি হন না',
           'প্রোফাইলের ছবি অতিরিক্ত পেশাদার মনে হয় বা সামাজিক মাধ্যম থেকে নেওয়া',
           'বিদেশে থাকা বাংলাদেশি বলে দাবি করেন এবং জরুরি সাহায্য চান',
           'দ্রুত হোয়াটসঅ্যাপ বা টেলিগ্রামে যেতে চাপ দেন',
           'চাকরি বা পরিবারের মতো গুরুত্বপূর্ণ বিষয়ে বারবার গল্প বদলান']))
  ]
}.freeze

# ===================== CONTACT (shown as plain text on the page) =====================
CONTACT = {
  heading: 'List your business',
  heading_bn: 'আপনার ব্যবসা যুক্ত করুন',
  address: 'Bolo Kobul head office, 14 Sir Iqbal Road, Khulna',
  content: 'Do you run a wedding-related business, such as a venue, decoration, photography, catering, flowers or makeup? Put it on the Bolo Kobul Wedding Shopping List for ৳1,000 a year and reach families who are planning a wedding right now. Tap “List your business” to apply.',
  content_bn: 'আপনার কি ভেন্যু, ডেকোরেশন, ফটোগ্রাফি, ক্যাটারিং, ফুল বা মেকআপের মতো বিয়ে-সংক্রান্ত কোনো ব্যবসা আছে? বছরে ৳১,০০০ দিয়ে বলো কবুলের ওয়েডিং শপিং লিস্টে যুক্ত হোন এবং এই মুহূর্তে বিয়ের পরিকল্পনা করছেন এমন পরিবারের কাছে পৌঁছান। আবেদন করতে “ব্যবসা যুক্ত করুন” চাপুন।'
}.freeze

# ===================== run =====================
if ARGV.first == 'undo'
  abort "No backup found at #{BACKUP}" unless File.exist?(BACKUP)
  JSON.parse(File.read(BACKUP)).each do |row|
    row['model'].constantize.find(row['id']).update_columns(row['attrs'])
  end
  puts "Undone: pages restored from #{BACKUP}"
  exit
end
abort "Already done (backup exists at #{BACKUP}). Run with 'undo' first to repeat it." if File.exist?(BACKUP)

backup = []
report = []
remember = lambda do |row, cols|
  next if backup.any? { |b| b['model'] == row.class.name && b['id'] == row.id }

  backup << { 'model' => row.class.name, 'id' => row.id, 'attrs' => row.attributes.slice(*cols.map(&:to_s)) }
end

PRIVACY.each do |title_word, (en, bn)|
  row = PrivacyPolicy.all.detect { |r| r[:title].to_s.include?(title_word) }
  next report << "  - Privacy \"#{title_word}…\" not found" unless row

  remember.call(row, %i[content content_bn])
  row.update_columns(content: en, content_bn: bn, updated_at: Time.current)
  report << "  ✓ Privacy: #{row[:title].to_s.truncate(50)}"
end

what = About.all.detect { |r| r[:content_type].to_s.include?('What we do') }
if what
  remember.call(what, %i[content content_bn])
  what.update_columns(content: ABOUT_WHAT_WE_DO[0], content_bn: ABOUT_WHAT_WE_DO[1], updated_at: Time.current)
  report << '  ✓ About: What we do'
else
  report << '  - About "What we do" not found'
end

ABOUT_EDITS.each do |type, col, olds, new_text|
  row = About.all.detect { |r| r[:content_type].to_s.include?(type) }
  next report << "  - About \"#{type}\" not found" unless row

  html = row[col].to_s
  hit = olds.detect { |o| html.match?(phrase(o)) }
  next report << "  - About #{type} (#{col}): \"#{olds.first.truncate(35)}\" not found" unless hit

  remember.call(row, %i[content content_bn])
  row.update_columns(col => html.gsub(phrase(hit)) { new_text }, updated_at: Time.current)
  report << "  ✓ About #{type}: \"#{hit.truncate(35)}\" → \"#{new_text.truncate(35)}\""
end

SAFETY.each do |title_word, (en, bn)|
  row = PrecautionaryMeasure.all.detect { |r| r[:title].to_s.include?(title_word) }
  next report << "  - Safety \"#{title_word}\" not found" unless row

  remember.call(row, %i[content content_bn])
  row.update_columns(content: en, content_bn: bn, updated_at: Time.current)
  report << "  ✓ Safety: #{row[:title]}"
end

if (contact = Contact.first)
  remember.call(contact, %i[heading heading_bn address content content_bn])
  contact.update_columns(CONTACT.merge(updated_at: Time.current))
  report << '  ✓ Contact: business section and head office address'
else
  report << '  - Contact not found'
end

File.write(BACKUP, JSON.pretty_generate(backup))
puts report
puts "Backup: #{BACKUP}"
