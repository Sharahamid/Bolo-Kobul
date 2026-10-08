# On-screen messages ("Saved successfully" and so on) are written in English in the
# controllers. On Bangla pages the known ones are shown in Bangla here; anything else
# is shown as written.
module FlashBanglaHelper
  FLASH_BANGLA = {
    'Your chatting option will be open after you send 2 Kobuls to a profile you like, and they accept it' =>
      'পছন্দের প্রোফাইলে ২টি কবুল পাঠানোর পর তারা গ্রহণ করলেই চ্যাট চালু হবে',
    'Marriage Information added successfully.' => 'বিয়ে-সংক্রান্ত তথ্য যোগ হয়েছে।',
    'Marriage Information updated successfully.' => 'বিয়ে-সংক্রান্ত তথ্য হালনাগাদ হয়েছে।',
    'Marriage Information failed to update. Try again' => 'বিয়ে-সংক্রান্ত তথ্য হালনাগাদ করা যায়নি। আবার চেষ্টা করুন',
    'Registration successful.' => 'নিবন্ধন সফল হয়েছে।',
    'Almost done! Enter the verification code we sent to your mobile.' => 'প্রায় শেষ! আপনার মোবাইলে পাঠানো যাচাই কোডটি লিখুন।',
    'Please choose Continue with Google or Facebook again.' => 'অনুগ্রহ করে আবার Google বা Facebook দিয়ে চালিয়ে যান বেছে নিন।',
    'Invalid request' => 'অনুরোধটি সঠিক নয়',
    'Signed in successfully.' => 'সফলভাবে লগইন হয়েছে।',
    'Invalid email or password.' => 'ইমেইল/মোবাইল বা পাসওয়ার্ড সঠিক নয়।',
    'Too many password reset requests. Please try again in an hour.' => 'পাসওয়ার্ড রিসেটের অনেক বেশি অনুরোধ হয়েছে। এক ঘণ্টা পর আবার চেষ্টা করুন।',
    "We couldn't send the reset email just now. Please try again later, or contact us from the Customer Support page." =>
      'এই মুহূর্তে রিসেট ইমেইল পাঠানো যায়নি। পরে আবার চেষ্টা করুন, অথবা গ্রাহক সহায়তা পাতা থেকে আমাদের জানান।',
    'Cultural Value added successfully.' => 'সাংস্কৃতিক মূল্যবোধ যোগ হয়েছে।',
    'Cultural Value updated successfully.' => 'সাংস্কৃতিক মূল্যবোধ হালনাগাদ হয়েছে।',
    'Added to your favourite list successfully.' => 'ফেভারিট তালিকায় যোগ হয়েছে।',
    'Removed from your favourite list.' => 'ফেভারিট তালিকা থেকে সরানো হয়েছে।',
    'Occupation updated successfully.' => 'পেশার তথ্য হালনাগাদ হয়েছে।',
    'Occupation failed to update. Try again' => 'পেশার তথ্য হালনাগাদ করা যায়নি। আবার চেষ্টা করুন',
    'Occupation deleted successfully.' => 'পেশার তথ্য মুছে ফেলা হয়েছে।',
    'Occupation failed to delete. Try again' => 'পেশার তথ্য মোছা যায়নি। আবার চেষ্টা করুন',
    'Submitted Successfully.' => 'সফলভাবে জমা হয়েছে।',
    'Privacy Updated Successfully.' => 'গোপনীয়তা সেটিং হালনাগাদ হয়েছে।',
    'Your account is already verified. Please log in.' => 'আপনার অ্যাকাউন্ট আগেই যাচাই করা হয়েছে। অনুগ্রহ করে লগইন করুন।',
    'This code has expired. Please request a new code.' => 'কোডটির মেয়াদ শেষ। নতুন কোড চেয়ে নিন।',
    'Too many incorrect attempts. Please request a new code.' => 'অনেকবার ভুল কোড দেওয়া হয়েছে। নতুন কোড চেয়ে নিন।',
    'Incorrect code, please try again' => 'কোডটি সঠিক নয়, আবার চেষ্টা করুন',
    'Verification code re-sent' => 'যাচাই কোড আবার পাঠানো হয়েছে',
    "We couldn't send the code just now. Please try again in a minute." => 'এই মুহূর্তে কোড পাঠানো যায়নি। এক মিনিট পর আবার চেষ্টা করুন।',
    'Please wait a minute before requesting another code.' => 'আরেকটি কোড চাওয়ার আগে এক মিনিট অপেক্ষা করুন।',
    'Password Changed Successfully' => 'পাসওয়ার্ড বদলানো সফল হয়েছে',
    'Deactivated Successfully' => 'অ্যাকাউন্ট নিষ্ক্রিয় করা হয়েছে',
    'Activated Successfully' => 'অ্যাকাউন্ট সক্রিয় করা হয়েছে',
    'Please enter your correct password and tick the box to confirm.' => 'সঠিক পাসওয়ার্ড দিন এবং নিশ্চিত করতে বক্সে টিক দিন।',
    'Deletion cancelled. Welcome back! Your account is active again.' => 'মুছে ফেলা বাতিল হয়েছে। আবার স্বাগতম! আপনার অ্যাকাউন্ট আবার সক্রিয়।',
    'Text Alert Activated' => 'এসএমএস সতর্কবার্তা চালু হয়েছে',
    'Text Alert Deactivated' => 'এসএমএস সতর্কবার্তা বন্ধ হয়েছে',
    'Advanced Search Enabled' => 'অ্যাডভান্সড সার্চ চালু হয়েছে',
    'Advanced Search Disabled' => 'অ্যাডভান্সড সার্চ বন্ধ হয়েছে',
    'Life Style added successfully.' => 'জীবনযাপনের তথ্য যোগ হয়েছে।',
    'Life Style updated successfully.' => 'জীবনযাপনের তথ্য হালনাগাদ হয়েছে।',
    'Please complete your marriage profile first' => 'আগে আপনার বিয়ের প্রোফাইল তৈরি করুন',
    'Please set preference' => 'অনুগ্রহ করে জীবনসঙ্গীর পছন্দ ঠিক করুন',
    'Hobbies and interest added successfully.' => 'শখ ও আগ্রহ যোগ হয়েছে।',
    'Hobbies and interest updated successfully.' => 'শখ ও আগ্রহ হালনাগাদ হয়েছে।',
    'This profile is not available.' => 'এই প্রোফাইলটি পাওয়া যাচ্ছে না।',
    'Basic information updated successfully' => 'মৌলিক তথ্য হালনাগাদ হয়েছে',
    'Photo uploaded successfully!' => 'ছবি আপলোড হয়েছে!',
    'Permission denied!' => 'অনুমতি নেই!',
    'About yourself updated successfully' => 'আপনার সম্পর্কে তথ্য হালনাগাদ হয়েছে',
    'You already have a connection with this profile!' => 'এই প্রোফাইলের সঙ্গে আপনার আগে থেকেই সংযোগ আছে!',
    'Your 1st Kobul has been sent successfully' => 'আপনার ১ম কবুল পাঠানো হয়েছে',
    'No pending request' => 'কোনো অপেক্ষমাণ অনুরোধ নেই',
    'Your 1st Kobul has been accepted successfully' => 'আপনি ১ম কবুল গ্রহণ করেছেন',
    '1st Kobul rejected' => '১ম কবুল প্রত্যাখ্যান করা হয়েছে',
    '1st Kobul cancelled, but you got your butterfly back!' => '১ম কবুল বাতিল হয়েছে, আপনার বাটারফ্লাই ফেরত পেয়েছেন!',
    "Blocked successfully. You won't see each other any more." => 'ব্লক করা হয়েছে। আপনারা আর একে অপরকে দেখতে পাবেন না।',
    'Unblocked Successfully' => 'আনব্লক করা হয়েছে',
    'Only the member who blocked this profile can unblock it' => 'যিনি ব্লক করেছেন, শুধু তিনিই আনব্লক করতে পারবেন',
    'Welcome to Bolokobul! Please complete your profile!' => 'বলো কবুলে স্বাগতম! অনুগ্রহ করে আপনার প্রোফাইল সম্পূর্ণ করুন!',
    'Preference updated successfully' => 'জীবনসঙ্গীর পছন্দ হালনাগাদ হয়েছে',
    'Referral code accepted! Register now to complete your profile.' => 'রেফারেল কোড গ্রহণ করা হয়েছে! প্রোফাইল সম্পূর্ণ করতে এখনই নিবন্ধন করুন।',
    'Appearance added successfully.' => 'চেহারার তথ্য যোগ হয়েছে।',
    'Appearance updated successfully.' => 'চেহারার তথ্য হালনাগাদ হয়েছে।',
    'Appearance failed to update. Try again' => 'চেহারার তথ্য হালনাগাদ করা যায়নি। আবার চেষ্টা করুন',
    'Family Details added successfully.' => 'পরিবারের তথ্য যোগ হয়েছে।',
    'Family Details updated successfully.' => 'পরিবারের তথ্য হালনাগাদ হয়েছে।',
    'Family Details failed to update. Try again' => 'পরিবারের তথ্য হালনাগাদ করা যায়নি। আবার চেষ্টা করুন',
    'Family Details deleted successfully.' => 'পরিবারের তথ্য মুছে ফেলা হয়েছে।',
    'Family Details failed to delete. Try again' => 'পরিবারের তথ্য মোছা যায়নি। আবার চেষ্টা করুন',
    'Reply sent successfully!' => 'উত্তর পাঠানো হয়েছে!',
    'Could not send reply.' => 'উত্তর পাঠানো যায়নি।',
    'You are already connected to chat!' => 'আপনারা আগে থেকেই চ্যাটে যুক্ত আছেন!',
    'Your 2nd Kobul has been sent successfully' => 'আপনার ২য় কবুল পাঠানো হয়েছে',
    'Your 2nd Kobul has been accepted successfully' => 'আপনি ২য় কবুল গ্রহণ করেছেন',
    '2nd Kobul rejected. Check out more profiles!' => '২য় কবুল প্রত্যাখ্যান করা হয়েছে। আরও প্রোফাইল দেখুন!',
    '2nd Kobul cancelled' => '২য় কবুল বাতিল হয়েছে',
    'Academic information added successfully.' => 'শিক্ষাগত তথ্য যোগ হয়েছে।',
    'Academic information updated successfully.' => 'শিক্ষাগত তথ্য হালনাগাদ হয়েছে।',
    'Academic information failed to update. Try again' => 'শিক্ষাগত তথ্য হালনাগাদ করা যায়নি। আবার চেষ্টা করুন',
    'Academic information deleted successfully.' => 'শিক্ষাগত তথ্য মুছে ফেলা হয়েছে।',
    'Academic information failed to delete. Try again' => 'শিক্ষাগত তথ্য মোছা যায়নি। আবার চেষ্টা করুন',
    "Your account is created, but we couldn't send your verification code just now. Please tap Resend Code in a minute." =>
      'আপনার অ্যাকাউন্ট তৈরি হয়েছে, কিন্তু এই মুহূর্তে যাচাই কোড পাঠানো যায়নি। এক মিনিট পর "আবার কোড পাঠান" চাপুন।',
    'Thanks for sharing your precious story with us!' => 'আপনার মূল্যবান গল্পটি আমাদের সঙ্গে শেয়ার করার জন্য ধন্যবাদ!'
  }.freeze

  FLASH_BANGLA_PATTERNS = [
    [/\ASigned in with (.+)\.\z/, '\1 দিয়ে লগইন হয়েছে।'],
    [/\AWe couldn't sign you in with (.+)\. Please try again, or log in with your email or mobile\.\z/,
     '\1 দিয়ে লগইন করা যায়নি। আবার চেষ্টা করুন, অথবা ইমেইল বা মোবাইল দিয়ে লগইন করুন।'],
    [/\AYour (.+) account didn't share a verified email address\. Please register with the form instead\.\z/,
     'আপনার \1 অ্যাকাউন্ট থেকে যাচাই করা ইমেইল পাওয়া যায়নি। অনুগ্রহ করে ফর্ম পূরণ করে নিবন্ধন করুন।'],
    [/\AYour account will be deleted on (.+)\. You can cancel any time before then\.\z/,
     '\1 তারিখে আপনার অ্যাকাউন্ট মুছে ফেলা হবে। এর আগে যেকোনো সময় বাতিল করতে পারবেন।'],
    [/\AComplete at least (\d+)% of your profile to send a Kobul\. Yours is (\d+)% now: add your education, occupation, family and photos\.\z/,
     'কবুল পাঠাতে প্রোফাইলের অন্তত \1% সম্পূর্ণ করুন। আপনার এখন \2%: শিক্ষা, পেশা, পরিবারের তথ্য ও ছবি যোগ করুন।']
  ].freeze

  def flash_text(message)
    return message unless I18n.locale == :bn && message.is_a?(String)

    text = message.strip
    return FLASH_BANGLA[text] if FLASH_BANGLA.key?(text)

    FLASH_BANGLA_PATTERNS.each do |pattern, bangla|
      match = text.match(pattern)
      next unless match

      return bangla.gsub(/\\(\d)/) { flash_bangla_value(match[Regexp.last_match(1).to_i]) }
    end
    message
  end

  private

  # Numbers in Bangla digits, dates such as "7 November 2026" in Bangla
  def flash_bangla_value(value)
    return local_digits(value) if value.match?(/\A\d+\z/)
    return local_date(Date.parse(value)) if value.match?(/\A\d{1,2} [A-Z][a-z]+ \d{4}\z/)

    value
  end
end
