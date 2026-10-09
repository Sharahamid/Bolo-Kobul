namespace :accounts do
  desc 'Erase accounts whose 30-day deletion period has ended (see AccountDeletionService), and sign-ups never verified within 7 days'
  task purge_deleted: :environment do
    User.due_for_deletion.find_each do |user|
      AccountDeletionService.call(user)
      Rails.logger.info("[accounts] erased account #{user.id} (deletion requested #{user.deletion_requested_at})")
    rescue StandardError => e
      Rails.logger.error("[accounts] could not erase account #{user.id}: #{e.class}: #{e.message}")
    end

    # Sign-ups never verified within 7 days (mostly bots) and with nothing in them
    removed = 0
    User.where(verified: [false, nil]).where('created_at < ?', 7.days.ago).find_each do |user|
      next if user.marriage_profiles.exists? || user.orders.exists?

      user.destroy
      removed += 1
    rescue StandardError => e
      Rails.logger.error("[accounts] could not remove unverified sign-up #{user.id}: #{e.class}: #{e.message}")
    end
    Rails.logger.info("[accounts] removed #{removed} unverified sign-ups older than 7 days")
  end
end
