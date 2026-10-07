# Notifications are saved in English. On Bangla pages the known sentences are shown in
# Bangla; links, profile IDs and names inside them stay as they are. Anything else
# (for example a message typed by the admin) is shown as written.
module NotificationBanglaHelper
  LINK = '(<a [^>]*>)'.freeze
  ID = '(\S+?)'.freeze

  NOTIFICATION_BANGLA = [
    [/\A#{ID} did not accept your 2nd Kobul! Keep exploring — the right match is out there!\z/,
     '\1 আপনার ২য় কবুল গ্রহণ করেননি। খুঁজতে থাকুন — সঠিক মানুষটি নিশ্চয়ই আছেন!'],
    [/\AA butterfly has fluttered your way! Someone is interested in getting to know you\. #{LINK}See Who<\/a>\z/,
     'একটি বাটারফ্লাই আপনার কাছে উড়ে এসেছে! কেউ একজন আপনাকে জানতে আগ্রহী। \1দেখুন কে</a>'],
    [/\AGood news! #{ID} has accepted your 1st Kobul! Send a 2nd Kobul to start chatting\. #{LINK}Check Their Profile<\/a>\z/,
     'সুখবর! \1 আপনার ১ম কবুল গ্রহণ করেছেন! চ্যাট শুরু করতে ২য় কবুল পাঠান। \2প্রোফাইল দেখুন</a>'],
    [/\ASorry, #{ID} did not accept your 1st Kobul! Do not give up — keep exploring!\z/,
     'দুঃখিত, \1 আপনার ১ম কবুল গ্রহণ করেননি। হাল ছাড়বেন না — খুঁজতে থাকুন!'],
    [/\AYou accepted a 1st Kobul! #{LINK}View Their Profile<\/a>: #{ID}\. Send 2nd Kobul to start chatting\z/,
     'আপনি একটি ১ম কবুল গ্রহণ করেছেন! \1প্রোফাইল দেখুন</a>: \2। চ্যাট শুরু করতে ২য় কবুল পাঠান'],
    [/\AYou have a new message from #{ID}\. #{LINK}Read and Reply<\/a>\z/,
     '\1 আপনাকে নতুন বার্তা পাঠিয়েছেন। \2পড়ুন ও উত্তর দিন</a>'],
    [/\AYou have cancelled your 1st Kobul request to #{ID}\. Your butterfly is on its way back!\z/,
     'আপনি \1-কে পাঠানো ১ম কবুলের অনুরোধ বাতিল করেছেন। আপনার বাটারফ্লাই ফেরত আসছে!'],
    [/\AYou have cancelled your 2nd Kobul to #{ID}\.\z/,
     'আপনি \1-কে পাঠানো ২য় কবুল বাতিল করেছেন।'],
    [/\AYou have declined #{ID}'s 2nd Kobul request\. Keep exploring other profiles\.\z/,
     'আপনি \1-এর ২য় কবুলের অনুরোধ প্রত্যাখ্যান করেছেন। অন্য প্রোফাইলগুলো দেখতে থাকুন।'],
    [/\AYou have received a butterfly from (.+) through a referral!\z/,
     'রেফারেলের মাধ্যমে \1-এর কাছ থেকে একটি বাটারফ্লাই পেয়েছেন!'],
    [/\AYou have run out of butterflies! Purchase more to continue exploring and connecting\. #{LINK}Get More Butterflies →<\/a>\z/,
     'আপনার বাটারফ্লাই শেষ! খোঁজা ও যোগাযোগ চালিয়ে যেতে আরও কিনুন। \1আরও বাটারফ্লাই নিন →</a>'],
    # Google Play app: the buying part is removed before this runs
    [/\AYou have run out of butterflies!\z/, 'আপনার বাটারফ্লাই শেষ!'],
    [/\AYou only have (\d+) butterfl(?:y|ies) left\. Get more to keep connecting with new profiles! #{LINK}Get More Butterflies →<\/a>\z/,
     'আপনার আর মাত্র \1টি বাটারফ্লাই বাকি। নতুন প্রোফাইলের সঙ্গে যোগাযোগ রাখতে আরও নিন! \2আরও বাটারফ্লাই নিন →</a>'],
    [/\AYou only have (\d+) butterfl(?:y|ies) left\.\z/, 'আপনার আর মাত্র \1টি বাটারফ্লাই বাকি।'],
    [/\AYour 1st Kobul has been sent successfully\. We will notify you as soon as they respond\. #{LINK}View Profile<\/a>\z/,
     'আপনার ১ম কবুল পাঠানো হয়েছে। উত্তর এলেই আপনাকে জানানো হবে। \1প্রোফাইল দেখুন</a>'],
    [/\AYour purchase was successful! You have received (\d+) Butterfl(?:y|ies)\. Enjoy!\z/,
     'কেনাকাটা সফল হয়েছে! আপনি \1টি বাটারফ্লাই পেয়েছেন। উপভোগ করুন!'],
    [/\AYour purchase was successful! You have received (.+)\. Enjoy!\z/,
     'কেনাকাটা সফল হয়েছে! আপনি পেয়েছেন: \1। উপভোগ করুন!'],
    [/\AYour support request has been updated\. #{LINK}See details<\/a>\z/,
     'আপনার সহায়তার অনুরোধে নতুন আপডেট আছে। \1বিস্তারিত দেখুন</a>']
  ].freeze

  def bangla_notification(text)
    text = text.to_s.strip
    NOTIFICATION_BANGLA.each do |pattern, bangla|
      match = text.match(pattern)
      next unless match

      # Plain counts get Bangla digits; links, names and profile IDs stay as they are
      return bangla.gsub(/\\(\d)/) do
        value = match[Regexp.last_match(1).to_i]
        value.match?(/\A\d+\z/) ? local_digits(value) : value
      end
    end
    text
  end
end
