# Applies the corrections in db/data/content_updates.yml to the English text of the
# site pages, and refreshes the Bangla text of the same sections from
# db/data/bangla_content. Safe to run more than once.
#
#   RAILS_ENV=production bin/rails site_content:update
namespace :site_content do
  desc 'Apply db/data/content_updates.yml to the site pages (English and Bangla)'
  task update: :environment do
    models = %w[About Contact Faq PrecautionaryMeasure PrivacyPolicy TermsOfUse ProcessFlow]
    bangla = Dir[Rails.root.join('db/data/bangla_content/*.yml')].flat_map { |f| YAML.load_file(f) }
                                                                 .index_by { |e| [e['model'], e['id']] }

    YAML.load_file(Rails.root.join('db/data/content_updates.yml')).each do |entry|
      name = entry.fetch('model')
      raise "Unknown model #{name}" unless models.include?(name)

      record = name.constantize.find_by(id: entry.fetch('id'))
      next puts("  not found: #{name} ##{entry['id']} (skipped)") unless record

      changes = (entry['set'] || {}).transform_values(&:strip)
      (entry['replace'] || []).each do |from, to|
        field = 'content'
        text = changes[field] || record.read_attribute(field).to_s
        if text.include?(from)
          changes[field] = text.gsub(from, to)
        elsif !text.include?(to)
          puts "  #{name} ##{record.id}: \"#{from}\" not found, please check this one in the admin panel"
        end
      end
      bangla.fetch([name, record.id], {}).fetch('fields', {}).each { |field, value| changes[field] = value.strip }

      record.update_columns(changes) if changes.any?
      puts "  #{name} ##{record.id}: updated"
    end
  end
end

# Adds the November 2026 FAQ section and practical blog posts from
# db/data/new_content_2026_11.yml (with covers from db/data/blog_covers).
# Safe to run more than once: anything already there (same title) is left alone.
#
#   RAILS_ENV=production bin/rails site_content:add_nov_2026
namespace :site_content do
  desc 'Add the Kobuls/Butterflies FAQ section and the practical blog posts'
  task add_nov_2026: :environment do
    data = YAML.load_file(Rails.root.join('db/data/new_content_2026_11.yml'))

    faq = data.fetch('faq')
    if Faq.exists?(title: faq['title'])
      puts "  FAQ already there: #{faq['title']}"
    else
      Faq.create!(title: faq['title'], title_bn: faq['title_bn'],
                  content: faq['content'].strip, content_bn: faq['content_bn'].strip,
                  display_order: Faq.maximum(:display_order).to_i + 1)
      puts "  FAQ added: #{faq['title']}"
    end

    data.fetch('blogs').each do |post|
      if Blog.exists?(title: post['title'])
        puts "  Blog already there: #{post['title']}"
        next
      end
      blog = Blog.new(title: post['title'], story: post['story'].strip, story_type: post['story_type'],
                      status: :approved, author: 'Bolo Kobul Team', email: 'support@bolokobul.com')
      cover = Rails.root.join('db/data/blog_covers', "#{post['cover']}.jpg")
      blog.image.attach(io: File.open(cover), filename: "#{post['cover']}.jpg", content_type: 'image/jpeg') if File.exist?(cover)
      blog.save!
      puts "  Blog added: #{post['title']} (/blogs/#{blog.slug})"
    end
  end
end
