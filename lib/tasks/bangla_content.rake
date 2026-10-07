# Fills the Bangla fields of the admin-written pages (About, Contact, FAQ, safety tips,
# privacy policy, terms, how it works) from db/data/bangla_content/*.yml.
#
#   RAILS_ENV=production bin/rails bangla_content:load
#
# Only empty Bangla fields are filled, so changes made later in the admin panel are
# kept. FORCE=1 overwrites them with the text from the files.
namespace :bangla_content do
  desc 'Fill the Bangla fields of the site pages from db/data/bangla_content'
  task load: :environment do
    models = %w[About Contact Faq PrecautionaryMeasure PrivacyPolicy TermsOfUse ProcessFlow]
    force = ENV['FORCE'] == '1'
    filled = skipped = 0

    Dir[Rails.root.join('db/data/bangla_content/*.yml')].sort.each do |file|
      YAML.load_file(file).each do |entry|
        name = entry.fetch('model')
        raise "Unknown model #{name} in #{File.basename(file)}" unless models.include?(name)

        record = name.constantize.find_by(id: entry.fetch('id'))
        unless record
          puts "  not found: #{name} ##{entry['id']} (skipped)"
          next
        end

        fields = entry.fetch('fields').select { |field, _| field.end_with?('_bn') && record.has_attribute?(field) }
        fields = fields.select { |field, _| record[field].blank? } unless force
        if fields.empty?
          skipped += 1
        else
          record.update_columns(fields.transform_values(&:strip))
          filled += 1
        end
      end
    end

    puts "Bangla content: #{filled} filled, #{skipped} already had Bangla (kept)."
  end
end
