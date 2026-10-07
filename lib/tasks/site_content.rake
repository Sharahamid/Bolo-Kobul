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
