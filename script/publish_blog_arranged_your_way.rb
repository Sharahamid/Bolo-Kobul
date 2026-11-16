# Publishes the blog article "Arranged, But Your Way" (16 Nov 2026) with its cover picture.
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/publish_blog_arranged_your_way.rb
# Undo (removes it):  RAILS_ENV=production bundle exec rails runner script/publish_blog_arranged_your_way.rb undo
# New picture only:   RAILS_ENV=production bundle exec rails runner script/publish_blog_arranged_your_way.rb image
TITLE = 'Arranged, But Your Way: How Young Bangladesh Is Rewriting Marriage'.freeze
IMAGE = Rails.root.join('script/blog_images/arranged-but-your-way.jpg')

STORY = <<~HTML.freeze
  <p><strong>Young Bangladeshis want a real say in who they marry, and their family's blessing too. Here is how the new arranged marriage works, and why it keeps the best of both.</strong></p>

  <h2>A marriage was once a family decision</h2>
  <p>Not long ago, a marriage in Bangladesh began in the drawing room, not in the heart. An aunt knew a family. A ghotok carried a biodata from house to house. Parents met over tea, talked about lineage, education and land, and the two people at the centre of it all often met only a few times before the wedding day.</p>
  <p>Many of those marriages were happy and lasted a lifetime. Our parents and grandparents are proof that a family's judgement can be wise. But ask a young professional in Dhaka, Khulna or London today, and you will hear something different: <em>"I want my family's blessing. I also want to choose."</em></p>

  <h2>What changed</h2>
  <p>The values did not change much. Life around them did.</p>
  <ul>
    <li><strong>We live further apart.</strong> Sons and daughters study in Dhaka, work in Chattogram or settle in the Gulf, Malaysia or the UK. The old network of neighbours and relatives no longer reaches every good match.</li>
    <li><strong>Women and men both have careers.</strong> Two working people want a partner who understands their schedule, ambitions and values, not just their family name.</li>
    <li><strong>Everyone has a phone.</strong> Young people already make big decisions online, from jobs to education. Finding a life partner the same way no longer feels strange.</li>
    <li><strong>Biodatas travel on WhatsApp.</strong> Families now forward photos and personal details to people they barely know. That is convenient, and also risky.</li>
  </ul>

  <h2>Not "love" or "arranged": the middle path</h2>
  <p>We often talk as if there are only two kinds of marriage: a love marriage the family must accept, or an arranged marriage the couple must accept. Real life in Bangladesh sits in between.</p>
  <p>Today, most young people want what we can call an <strong>arranged-but-chosen</strong> marriage. The two people get to know each other first, at their own pace. If it feels right, the families come in, ask their questions and give their blessing. Nobody is pushed, and nobody is left out.</p>
  <p>The difference is not <em>who decides</em>. It is <em>who opens the door</em>. Sometimes it is the parents, sometimes the candidate. Either way, the final "Kobul" is said by two people who chose each other, with their families standing behind them.</p>

  <h2>What both sides want</h2>
  <table style="width:100%; border-collapse:collapse; margin:8px 0 16px;">
    <thead>
      <tr><th style="text-align:left; padding:8px 10px; background:#FAEEDA; border:1px solid #F3E3BD;">Young people want</th><th style="text-align:left; padding:8px 10px; background:#FAEEDA; border:1px solid #F3E3BD;">Families want</th></tr>
    </thead>
    <tbody>
      <tr><td style="padding:8px 10px; border:1px solid #F3E3BD;">A real say in who they marry</td><td style="padding:8px 10px; border:1px solid #F3E3BD;">Their child to be safe and respected</td></tr>
      <tr><td style="padding:8px 10px; border:1px solid #F3E3BD;">Time to talk before any commitment</td><td style="padding:8px 10px; border:1px solid #F3E3BD;">Honest details about education, work and family</td></tr>
      <tr><td style="padding:8px 10px; border:1px solid #F3E3BD;">Privacy: no phone number or photos shared with strangers</td><td style="padding:8px 10px; border:1px solid #F3E3BD;">Their family's name protected</td></tr>
      <tr><td style="padding:8px 10px; border:1px solid #F3E3BD;">Someone who shares their values and lifestyle</td><td style="padding:8px 10px; border:1px solid #F3E3BD;">A match that fits their faith and traditions</td></tr>
      <tr><td style="padding:8px 10px; border:1px solid #F3E3BD;">No pressure if it does not work out</td><td style="padding:8px 10px; border:1px solid #F3E3BD;">A respectful way to say no</td></tr>
    </tbody>
  </table>
  <p>Read the two columns side by side and they are not in conflict. Both want a good, honest match, made safely. What has been missing is a way to do it that serves both.</p>

  <h2>How Bolo Kobul's 3 Kobul journey fits</h2>
  <p>Bolo Kobul was built for this middle path. A profile can be created by the candidate, or by a parent, sibling or matchmaker with the candidate's permission. From there, every step needs both sides to say yes:</p>
  <ol>
    <li><strong>1st Kobul: getting to know each other.</strong> Send a 1st Kobul to a profile you like. If they accept, you can both see each other's full profiles: education, family and values. No contact details are shared.</li>
    <li><strong>2nd Kobul: start chatting.</strong> If you would like to know more, send a 2nd Kobul. If they accept, a private chat opens on Bolo Kobul. Your phone number stays private until you choose to share it.</li>
    <li><strong>3rd Kobul: the final "Kobul".</strong> This one does not happen on the website. When two people like each other after chatting and their families agree, they say the final "Kobul" at their wedding.</li>
  </ol>
  <p>Along the way, every member is phone-verified, profiles with a checked ID show a Verified badge, and anyone can be blocked or reported in one tap. Families stay involved as much as the candidate wants them to be.</p>

  <h2>Tradition, with your choice in it</h2>
  <p>The new arranged marriage keeps what was always good about the old one: family wisdom, shared values and a blessing on the wedding day. It adds what young Bangladesh is asking for: time, privacy and a real choice.</p>
  <p>Whether you are looking for yourself or helping a son, daughter or sibling, you can start today. Registration on <a href="https://bolokobul.com">Bolo Kobul</a> is free, and it takes only a few minutes.</p>
  <p><strong>Your story, your choice, your Kobul.</strong> <a href="https://bolokobul.com">Create your free profile &rarr;</a></p>
HTML

if ARGV.first == 'undo'
  blog = Blog.find_by(title: TITLE)
  abort 'Not found: nothing to remove.' unless blog
  blog.destroy!
  puts "Removed: #{TITLE}"
  exit
end

if ARGV.first == 'image'
  blog = Blog.find_by(title: TITLE)
  abort 'Not published yet: run the script without "image" first.' unless blog
  blog.image.attach(io: File.open(IMAGE), filename: 'arranged-but-your-way.jpg', content_type: 'image/jpeg')
  blog.touch
  puts "Picture replaced: https://bolokobul.com/blogs/#{blog.slug}"
  exit
end

if (existing = Blog.find_by(title: TITLE))
  abort "Already published: https://bolokobul.com/blogs/#{existing.slug}"
end

blog = Blog.new(title: TITLE, author: 'Bolo Kobul Team', email: 'support@bolokobul.com',
                story: STORY, story_type: :blog, status: :approved)
blog.image.attach(io: File.open(IMAGE), filename: 'arranged-but-your-way.jpg', content_type: 'image/jpeg') if File.exist?(IMAGE)
blog.save!
puts "Published: https://bolokobul.com/blogs/#{blog.slug}"
puts "(Picture: #{blog.image.attached? ? 'added' : 'missing - add one in Admin > Website > Blogs & Stories'})"
