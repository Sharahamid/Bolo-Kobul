# One-off content update (14 Nov 2026): FAQ sections 1–8 rewritten to match how the site
# works today (2 Kobuls, Kobul expiry, photos, login, search, chat replies...). English and
# Bangla. Section titles are not changed; sections 9–13 are not touched.
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/faq_sections_1_8.rb
# Undo:               RAILS_ENV=production bundle exec rails runner script/faq_sections_1_8.rb undo
require 'json'
require 'erb'

BACKUP = File.expand_path('~/faq_sections_1_8_backup.json')

# [display order, word that must be in the English title, [[question, answer], ...] EN, BN]
SECTIONS = [
  [1, 'how it works',
   [['Is this site only for people whose goal is marriage?', 'Yes. Bolo Kobul is only for finding a life partner for marriage. It is not a dating site.'],
    ['Who is the candidate and who is the submitter?', "The candidate is the person who wants to get married. The submitter is the person who registers the profile – the candidate themselves, or a parent, sibling, relative, friend or matchmaker with the candidate's permission."],
    ['How does Bolo Kobul work?', "1. Create a free profile and set your partner preferences. 2. Browse your recommendations and search. 3. Send a 1st Kobul to someone you like; if they accept, you both see each other's photos and full details. 4. Send a 2nd Kobul; if they accept, chat opens. Phone numbers are never shown."],
    ['What are butterflies?', 'Butterflies are used to send and accept Kobuls. New members get free butterflies, and you can buy more from Orders at any time. See "Kobuls, Butterflies & Privacy" for details.'],
    ['How long does a 1st Kobul wait for an answer?', 'A 1st Kobul stays open for a set number of days (currently 7). The receiver gets a reminder 2 days before it ends. If there is no answer, it closes and the sender gets the butterflies back. 2nd Kobuls do not expire.'],
    ['What are Assisted Services?', 'Optional paid help from our team: Get Verified, help filling in your profile, and an experienced matchmaker who shortlists profiles for you and can join your first meeting. Fees are paid on the website; you never pay a matchmaker in person.'],
    ['What is free and what is paid?', 'Registration, your profile, search, recommendations and the free butterflies for new members are free, and chat opens free once both Kobuls are accepted. Paid options: more butterflies, BK+ membership, Assisted Services, and text (SMS) alerts paid with butterflies.']],
   [['এই সাইট কি শুধু বিয়ের উদ্দেশ্যে?', 'হ্যাঁ। বলো কবুল শুধু বিয়ের জন্য জীবনসঙ্গী খোঁজার জায়গা। এটি কোনো ডেটিং সাইট নয়।'],
    ['পাত্র/পাত্রী কে, আর প্রোফাইল জমাদানকারী কে?', 'যিনি বিয়ে করবেন তিনিই পাত্র/পাত্রী। যিনি প্রোফাইলটি নিবন্ধন করেন তিনি জমাদানকারী – পাত্র/পাত্রী নিজে, অথবা তাঁর অনুমতি নিয়ে মা-বাবা, ভাই/বোন, আত্মীয়, বন্ধু বা ঘটক।'],
    ['বলো কবুল কীভাবে কাজ করে?', '১. বিনামূল্যে প্রোফাইল তৈরি করে জীবনসঙ্গীর পছন্দ ঠিক করুন। ২. সুপারিশ দেখুন ও খুঁজুন। ৩. পছন্দের কাউকে ১ম কবুল পাঠান; তিনি গ্রহণ করলে দুজনেই একে অপরের ছবি ও পূর্ণ তথ্য দেখতে পাবেন। ৪. ২য় কবুল পাঠান; গ্রহণ করলে চ্যাট চালু হয়। ফোন নম্বর কখনো দেখানো হয় না।'],
    ['বাটারফ্লাই কী?', 'কবুল পাঠাতে ও গ্রহণ করতে বাটারফ্লাই লাগে। নতুন সদস্যরা বিনামূল্যে বাটারফ্লাই পান, আর যেকোনো সময় অর্ডার থেকে আরও কিনতে পারেন। বিস্তারিত “কবুল, বাটারফ্লাই ও গোপনীয়তা” অংশে।'],
    ['১ম কবুল কতদিন উত্তরের অপেক্ষায় থাকে?', '১ম কবুল নির্দিষ্ট কয়েক দিন খোলা থাকে (এখন ৭ দিন)। শেষ হওয়ার ২ দিন আগে প্রাপককে মনে করিয়ে দেওয়া হয়। উত্তর না এলে এটি বন্ধ হয়ে যায় এবং প্রেরক বাটারফ্লাই ফেরত পান। ২য় কবুলের মেয়াদ শেষ হয় না।'],
    ['সহায়তা সেবা কী?', 'আমাদের টিমের ঐচ্ছিক পেইড সহায়তা: ভেরিফাইড হওয়া, প্রোফাইল পূরণে সাহায্য, এবং অভিজ্ঞ ঘটক যিনি আপনার জন্য প্রোফাইল বাছাই করবেন ও প্রথম সাক্ষাতে সঙ্গে থাকতে পারবেন। ফি ওয়েবসাইটেই দিতে হয়; ঘটককে হাতে কোনো টাকা দিতে হয় না।'],
    ['কী বিনামূল্যে আর কী পেইড?', 'নিবন্ধন, প্রোফাইল, খোঁজা, সুপারিশ এবং নতুন সদস্যদের বিনামূল্যের বাটারফ্লাই ফ্রি, আর দুটি কবুল গ্রহণ হলে চ্যাটও ফ্রি। পেইড সুবিধা: আরও বাটারফ্লাই, BK+ মেম্বারশিপ, সহায়তা সেবা, এবং বাটারফ্লাই দিয়ে চালু করা টেক্সট (SMS) অ্যালার্ট।']]],
  [2, 'regist',
   [['How do I register?', 'Sign up with your mobile number, Google or Facebook, and enter the code we send to your phone. Registration is free.'],
    ['Can I register for a family member or friend?', 'Yes. Choose who the profile is for (parent, sibling, relative, friend, colleague, child or matchmaker) and tick the box confirming you have their permission, the details are true and they are of legal marriage age (21 for men, 18 for women).'],
    ['How long does it take?', 'A few minutes to register, and around 10 minutes to complete the profile steps. You can save and finish later.'],
    ['Can I fill the form from my biodata?', 'Yes. On the first step you can upload your biodata (PDF, Word file or photo) and we fill in what we can read. Check every detail before pressing Next.'],
    ['My answer is not in the list. What do I do?', 'Choose "Other" and type your answer, or write to support@bolokobul.com and we will consider adding it.'],
    ['What is a Profile ID?', 'Every profile gets an ID such as BK0000123. Other members see this ID instead of your name, so your identity stays private.'],
    ['Why set partner preferences?', 'Your preferences decide your daily recommendations and the match % shown on every profile.'],
    ['How do I get the Verified badge?', 'Upload your NID or passport in your profile, or choose Get Verified in Assisted Services. Once our team checks it, a Verified badge appears on your profile.']],
   [['কীভাবে নিবন্ধন করব?', 'মোবাইল নম্বর, গুগল বা ফেসবুক দিয়ে সাইন আপ করুন এবং ফোনে পাঠানো কোডটি দিন। নিবন্ধন বিনামূল্যে।'],
    ['পরিবারের কারো বা বন্ধুর জন্য নিবন্ধন করতে পারি?', 'হ্যাঁ। প্রোফাইলটি কার জন্য (মা-বাবা, ভাই/বোন, আত্মীয়, বন্ধু, সহকর্মী, সন্তান বা ঘটক) তা বেছে নিন, এবং টিক দিয়ে নিশ্চিত করুন যে তাঁর অনুমতি আছে, তথ্য সত্য এবং তাঁর বয়স বিয়ের আইনগত বয়সের সমান বা বেশি (ছেলেদের ২১, মেয়েদের ১৮)।'],
    ['কত সময় লাগে?', 'নিবন্ধনে কয়েক মিনিট, আর প্রোফাইলের ধাপগুলো শেষ করতে প্রায় ১০ মিনিট। চাইলে সংরক্ষণ করে পরে শেষ করতে পারেন।'],
    ['বায়োডাটা থেকে ফর্ম পূরণ করা যায়?', 'হ্যাঁ। প্রথম ধাপে আপনার বায়োডাটা (PDF, Word ফাইল বা ছবি) আপলোড করলে যতটুকু পড়া যায় আমরা পূরণ করে দিই। “পরবর্তী” চাপার আগে প্রতিটি তথ্য যাচাই করুন।'],
    ['আমার উত্তর তালিকায় নেই। কী করব?', '“অন্যান্য” বেছে নিয়ে আপনার উত্তর লিখুন, অথবা support@bolokobul.com এ লিখুন – আমরা যোগ করার কথা বিবেচনা করব।'],
    ['প্রোফাইল আইডি কী?', 'প্রতিটি প্রোফাইল একটি আইডি পায়, যেমন BK0000123। অন্য সদস্যরা আপনার নামের বদলে এই আইডি দেখেন, তাই আপনার পরিচয় গোপন থাকে।'],
    ['জীবনসঙ্গীর পছন্দ কেন ঠিক করব?', 'আপনার পছন্দ অনুযায়ীই প্রতিদিনের সুপারিশ আর প্রতিটি প্রোফাইলে দেখানো ম্যাচ % ঠিক হয়।'],
    ['ভেরিফায়েড ব্যাজ কীভাবে পাব?', 'প্রোফাইলে আপনার এনআইডি বা পাসপোর্ট আপলোড করুন, অথবা সহায়তা সেবা থেকে “ভেরিফায়েড হোন” বেছে নিন। আমাদের টিম যাচাই করলে প্রোফাইলে ভেরিফায়েড ব্যাজ দেখা যাবে।']]],
  [3, 'login',
   [['How long do I stay logged in?', 'On the website you stay logged in for 3 days. In the Bolo Kobul app you stay logged in until you log out.'],
    ['I forgot my password.', 'Tap "Forgot Password?" on the login box and enter your email. We email you a link to set a new password. We never send your password itself.'],
    ['What makes a valid password?', 'At least 8 characters, with a capital letter, a small letter, a number and a symbol.'],
    ['How do I change my password?', 'Open Account Settings from the menu and choose Change next to Password.'],
    ['Can other members see when I am online?', 'They can see roughly when you were last active (for example "Active today"), never your exact activity.']],
   [['কতদিন লগ ইন থাকব?', 'ওয়েবসাইটে ৩ দিন লগ ইন থাকবেন। বলো কবুল অ্যাপে লগ আউট না করা পর্যন্ত লগ ইন থাকবেন।'],
    ['পাসওয়ার্ড ভুলে গেছি।', 'লগ ইন বক্সে “পাসওয়ার্ড ভুলে গেছেন?” চাপুন এবং আপনার ইমেইল দিন। নতুন পাসওয়ার্ড দেওয়ার একটি লিংক ইমেইলে পাঠানো হবে। আমরা কখনো আপনার পাসওয়ার্ড পাঠাই না।'],
    ['বৈধ পাসওয়ার্ড কেমন হবে?', 'কমপক্ষে ৮ অক্ষর, যাতে একটি বড় হাতের অক্ষর, একটি ছোট হাতের অক্ষর, একটি সংখ্যা ও একটি চিহ্ন থাকবে।'],
    ['পাসওয়ার্ড কীভাবে বদলাব?', 'মেনু থেকে অ্যাকাউন্ট সেটিংস খুলে পাসওয়ার্ডের পাশে “পরিবর্তন” চাপুন।'],
    ['আমি অনলাইনে আছি কি না অন্যরা দেখতে পায়?', 'তারা মোটামুটি দেখতে পায় শেষ কবে সক্রিয় ছিলেন (যেমন “আজ সক্রিয়”), কিন্তু আপনার সঠিক কার্যকলাপ কখনো নয়।']]],
  [4, 'profile management',
   [['How do I edit my profile?', 'Open Profile from the menu and tap Edit on any section.'],
    ['Which details can I not change myself?', 'Your date of birth, gender and a few key details are locked to protect other members. If something is wrong, write to support@bolokobul.com with the reason.'],
    ['Can I hide my profile for a while?', 'Yes. In Account Settings choose Deactivate. Your profile is hidden until you activate it again.'],
    ['How do I delete my account?', 'In Account Settings choose Delete Account. Your account is hidden straight away and erased after 30 days. You can cancel within those 30 days.'],
    ['Will my profile appear on Google?', 'No. Profiles are only visible to signed-in members. Do not write your name or contact details in "About me".'],
    ['We got married through Bolo Kobul!', 'Congratulations! Send us your story from Success Stories and we will be happy to share it.']],
   [['প্রোফাইল কীভাবে সম্পাদনা করব?', 'মেনু থেকে প্রোফাইল খুলে যেকোনো অংশে “সম্পাদনা” চাপুন।'],
    ['কোন তথ্য নিজে বদলানো যায় না?', 'অন্য সদস্যদের সুরক্ষার জন্য জন্মতারিখ, লিঙ্গ ও কয়েকটি গুরুত্বপূর্ণ তথ্য লক করা থাকে। ভুল থাকলে কারণসহ support@bolokobul.com এ লিখুন।'],
    ['কিছুদিনের জন্য প্রোফাইল লুকাতে পারি?', 'হ্যাঁ। অ্যাকাউন্ট সেটিংসে “নিষ্ক্রিয় করুন” বেছে নিন। আবার সক্রিয় না করা পর্যন্ত প্রোফাইল লুকানো থাকবে।'],
    ['অ্যাকাউন্ট কীভাবে মুছব?', 'অ্যাকাউন্ট সেটিংসে “অ্যাকাউন্ট মুছুন” বেছে নিন। অ্যাকাউন্ট সঙ্গে সঙ্গে লুকানো হয় এবং ৩০ দিন পর মুছে ফেলা হয়। এই ৩০ দিনের মধ্যে বাতিল করতে পারবেন।'],
    ['আমার প্রোফাইল কি গুগলে দেখা যাবে?', 'না। প্রোফাইল শুধু লগ ইন করা সদস্যরা দেখতে পান। “আমার সম্পর্কে” অংশে নাম বা যোগাযোগের তথ্য লিখবেন না।'],
    ['বলো কবুলের মাধ্যমে আমাদের বিয়ে হয়েছে!', 'অভিনন্দন! সাফল্যের গল্প অংশ থেকে আপনাদের গল্প পাঠান – আমরা আনন্দের সঙ্গে শেয়ার করব।']]],
  [5, 'photo',
   [['Why add photos?', 'Members are far more likely to send a Kobul to a profile with a photo. You can add up to 4 photos (1 main + 3 more).'],
    ['Who can see my photos?', 'Only members whose 1st Kobul you accept, or who accept yours. Others see your profile without photos.'],
    ['Are my photos protected?', "Photos cannot be saved by long-press, right-click or dragging, and enlarged photos carry a faint watermark with the viewer's Profile ID, so a screenshot shows who took it."],
    ['Which files can I upload?', 'JPG, PNG or GIF photos. Large photos are made smaller automatically before uploading.']],
   [['ছবি কেন যোগ করব?', 'ছবি থাকা প্রোফাইলে সদস্যরা অনেক বেশি কবুল পাঠান। আপনি সর্বোচ্চ ৪টি ছবি যোগ করতে পারেন (১টি প্রধান + আরও ৩টি)।'],
    ['আমার ছবি কারা দেখতে পায়?', 'শুধু যাঁদের ১ম কবুল আপনি গ্রহণ করেছেন, অথবা যাঁরা আপনার ১ম কবুল গ্রহণ করেছেন। অন্যরা ছবি ছাড়া আপনার প্রোফাইল দেখেন।'],
    ['আমার ছবি কি সুরক্ষিত?', 'লং-প্রেস, রাইট-ক্লিক বা টেনে এনে ছবি সেভ করা যায় না, এবং বড় করে দেখা ছবিতে দর্শকের প্রোফাইল আইডিসহ হালকা ওয়াটারমার্ক থাকে, ফলে স্ক্রিনশট কে নিয়েছে বোঝা যায়।'],
    ['কোন ধরনের ফাইল আপলোড করা যায়?', 'JPG, PNG বা GIF ছবি। বড় ছবি আপলোডের আগে নিজে থেকেই ছোট করে নেওয়া হয়।']]],
  [6, 'search',
   [['How do I find matches?', 'Your dashboard shows recommendations picked from your preferences every day (10 a day, 20 with BK+). You can also use Search with filters such as age, religion, district and education.'],
    ['What is Advanced Search?', 'Extra filters such as height, marital status, occupation and present location. Turn it on in Account Settings or on the search page; if it uses butterflies, the cost is shown before you turn it on.'],
    ['What does the match % mean?', 'How closely a profile fits your preferences, and you fit theirs.'],
    ['What does "Not interested" do?', 'It hides that profile from your recommendations and search. You can bring it back from Blocked & hidden profiles.'],
    ['Can I save profiles?', 'Yes, tap Favourite. Find them under Favourites.'],
    ['Can I see who viewed my profile?', 'Everyone sees how many people viewed their profile. BK+ members also see who viewed it in the last 30 days.']],
   [['কীভাবে ম্যাচ খুঁজব?', 'আপনার ড্যাশবোর্ডে প্রতিদিন আপনার পছন্দ অনুযায়ী সুপারিশ দেখানো হয় (দিনে ১০টি, BK+ এ ২০টি)। এছাড়া বয়স, ধর্ম, জেলা ও শিক্ষার মতো ফিল্টার দিয়ে খুঁজতে পারেন।'],
    ['অ্যাডভান্সড সার্চ কী?', 'উচ্চতা, বৈবাহিক অবস্থা, পেশা ও বর্তমান ঠিকানার মতো অতিরিক্ত ফিল্টার। অ্যাকাউন্ট সেটিংস বা সার্চ পেজ থেকে চালু করুন; বাটারফ্লাই লাগলে চালুর আগেই খরচ দেখানো হয়।'],
    ['ম্যাচ % মানে কী?', 'একটি প্রোফাইল আপনার পছন্দের সাথে, আর আপনি তাঁর পছন্দের সাথে কতটা মেলেন।'],
    ['“আগ্রহী নই” কী করে?', 'প্রোফাইলটি আপনার সুপারিশ ও খোঁজার ফলাফল থেকে লুকিয়ে ফেলে। “ব্লক ও লুকানো প্রোফাইল” থেকে আবার ফিরিয়ে আনতে পারবেন।'],
    ['প্রোফাইল সেভ করে রাখা যায়?', 'হ্যাঁ, “ফেভারিট” চাপুন। ফেভারিট তালিকায় পাবেন।'],
    ['কে আমার প্রোফাইল দেখেছে জানা যায়?', 'সবাই দেখতে পান কতজন তাঁর প্রোফাইল দেখেছেন। BK+ সদস্যরা গত ৩০ দিনে কে দেখেছেন তাও দেখতে পান।']]],
  [7, 'contact',
   [['How do I contact a member?', 'Send a 1st Kobul. When they accept, send a 2nd Kobul; when that is accepted, chat opens. Strangers can never message you.'],
    ['What if I am not interested in a Kobul I received?', 'Tap Reject. For a 1st Kobul the sender gets their butterflies back. If you do nothing, a 1st Kobul closes on its own after the set number of days.'],
    ['Can I cancel a Kobul I sent?', 'Yes, from Requests Sent (1st Kobul) or Chat Requests Sent (2nd Kobul). Butterflies come back for a 1st Kobul, not for a 2nd Kobul.'],
    ['Can Customer Support contact a member for me?', 'No. Our team does not contact members on your behalf. Assisted Services can give you a matchmaker.']],
   [['কোনো সদস্যের সাথে কীভাবে যোগাযোগ করব?', '১ম কবুল পাঠান। তিনি গ্রহণ করলে ২য় কবুল পাঠান; সেটি গ্রহণ হলে চ্যাট চালু হয়। অপরিচিত কেউ কখনো আপনাকে মেসেজ পাঠাতে পারে না।'],
    ['পাওয়া কোনো কবুলে আগ্রহী না হলে?', '“প্রত্যাখ্যান” চাপুন। ১ম কবুলের ক্ষেত্রে প্রেরক বাটারফ্লাই ফেরত পান। কিছু না করলে নির্দিষ্ট দিন পর ১ম কবুল নিজেই বন্ধ হয়ে যায়।'],
    ['পাঠানো কবুল বাতিল করা যায়?', 'হ্যাঁ, পাঠানো অনুরোধ (১ম কবুল) বা পাঠানো চ্যাট অনুরোধ (২য় কবুল) থেকে। ১ম কবুলের বাটারফ্লাই ফেরত আসে, ২য় কবুলের নয়।'],
    ['কাস্টমার সাপোর্ট কি আমার হয়ে যোগাযোগ করতে পারে?', 'না। আমাদের টিম আপনার পক্ষে সদস্যদের সাথে যোগাযোগ করে না। সহায়তা সেবা থেকে ঘটক নিতে পারেন।']]],
  [8, 'chat',
   [['Who can I chat with?', 'Only members with whom both the 1st and the 2nd Kobul have been accepted. Phone numbers stay hidden – share yours only when you are comfortable.'],
    ['Can I reply to a particular message?', 'Yes. Swipe a message to the right on a phone, or press ↩ beside it on a computer.'],
    ['I do not want to continue a chat.', 'Tell the person politely, or use Report & Block from the ⋮ menu. Blocking closes the chat at once.']],
   [['কার সাথে চ্যাট করতে পারব?', 'শুধু যাঁদের সাথে ১ম ও ২য় দুটি কবুলই গ্রহণ হয়েছে। ফোন নম্বর গোপন থাকে – স্বস্তি বোধ করলে তবেই নিজের নম্বর দিন।'],
    ['নির্দিষ্ট কোনো মেসেজের উত্তর দেওয়া যায়?', 'হ্যাঁ। ফোনে মেসেজটি ডান দিকে সোয়াইপ করুন, অথবা কম্পিউটারে পাশের ↩ চাপুন।'],
    ['চ্যাট আর চালিয়ে যেতে চাই না।', 'ভদ্রভাবে জানিয়ে দিন, অথবা ⋮ মেনু থেকে “রিপোর্ট ও ব্লক” ব্যবহার করুন। ব্লক করলে চ্যাট সঙ্গে সঙ্গে বন্ধ হয়ে যায়।']]]
].freeze

NUMBERED = /(?:\A|\s)(?:\d+|[০-৯]+)\.\s/

# An answer written as "1. ... 2. ... 3. ..." becomes a numbered list, one step per line
def answer_html(text)
  return "<p>#{ERB::Util.html_escape(text)}</p>" unless text.match?(/\A(?:1|১)\.\s/)

  steps = text.split(/(?:\A|\s+)(?:\d+|[০-৯]+)\.\s+/).reject(&:blank?)
  "<ol>\n#{steps.map { |s| "<li>#{ERB::Util.html_escape(s.strip)}</li>" }.join("\n")}\n</ol>"
end

def to_html(pairs)
  pairs.map { |q, a| "<p><strong>#{ERB::Util.html_escape(q)}</strong></p>\n#{answer_html(a)}" }.join("\n")
end

if ARGV.first == 'undo'
  abort "No backup found at #{BACKUP}" unless File.exist?(BACKUP)
  JSON.parse(File.read(BACKUP)).each do |row|
    Faq.find(row['id']).update_columns(content: row['content'], content_bn: row['content_bn'])
  end
  puts "Undone: FAQ sections restored from #{BACKUP}"
  exit
end
abort "Already done (backup exists at #{BACKUP}). Run with 'undo' first to repeat it." if File.exist?(BACKUP)

backup = []
SECTIONS.each do |order, word, en, bn|
  faq = Faq.where(display_order: order).detect { |f| f.title.to_s.downcase.include?(word) } ||
        Faq.all.detect { |f| f.title.to_s.downcase.include?(word) && f.display_order.to_i <= 8 }
  if faq.nil?
    puts "  - Section #{order} (\"#{word}\") not found, skipped"
    next
  end
  backup << { id: faq.id, content: faq.content, content_bn: faq.content_bn }
  faq.update_columns(content: to_html(en), content_bn: to_html(bn), updated_at: Time.current)
  puts "  ✓ #{order}. #{faq.title.to_s.squish} (#{en.size} questions)"
end
File.write(BACKUP, JSON.pretty_generate(backup))
puts "Done. Backup: #{BACKUP}"
