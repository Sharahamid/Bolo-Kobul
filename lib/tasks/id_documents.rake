# Moves ID documents (NID, passport) uploaded before October 2026 out of the public folder,
# where anyone who knew the address could open them, into private storage.
# Safe to run more than once: RAILS_ENV=production bin/rails id_documents:make_private
namespace :id_documents do
  desc 'Move ID documents from public/uploads to private storage'
  task make_private: :environment do
    old_root = Rails.root.join('public', 'uploads', 'marriage_profile', 'identification_document')
    moved = already = missing = 0

    MarriageProfile.where.not(identification_document: [nil, '']).find_each do |profile|
      name = profile.read_attribute(:identification_document)
      old_path = old_root.join(profile.id.to_s, name)
      new_path = profile.identification_document.path

      if File.exist?(new_path)
        already += 1
      elsif File.exist?(old_path)
        FileUtils.mkdir_p(File.dirname(new_path))
        FileUtils.mv(old_path, new_path)
        moved += 1
      else
        missing += 1
        puts "No file found for profile #{profile.unique_id} (#{name})"
      end
    end

    # Remove the now-empty public folders
    Dir.glob(old_root.join('*')).each { |dir| Dir.rmdir(dir) if File.directory?(dir) && Dir.empty?(dir) }

    left = Dir.glob(old_root.join('**', '*')).count { |f| File.file?(f) }
    puts "Moved #{moved} ID documents to private storage, #{already} were already private, #{missing} missing."
    puts left.zero? ? 'No ID documents are left in the public folder.' : "#{left} files are still in #{old_root} (not linked to any profile): check and delete them."
  end
end
