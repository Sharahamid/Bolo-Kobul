namespace :profiles do
  desc 'Recalculate profile completeness for every profile (after changes to how it is counted)'
  task recalculate_completeness: :environment do
    changed = 0
    MarriageProfile.find_each do |profile|
      before = profile.profile_completeness.to_i
      profile.progress_recalculate
      changed += 1 if profile.reload.profile_completeness.to_i != before
    end
    puts "Recalculated #{MarriageProfile.count} profiles, #{changed} changed."
  end
end
