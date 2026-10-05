namespace :accounts do
  desc 'Erase accounts whose 30-day deletion period has ended (see AccountDeletionService)'
  task purge_deleted: :environment do
    User.due_for_deletion.find_each do |user|
      AccountDeletionService.call(user)
      Rails.logger.info("[accounts] erased account #{user.id} (deletion requested #{user.deletion_requested_at})")
    rescue StandardError => e
      Rails.logger.error("[accounts] could not erase account #{user.id}: #{e.class}: #{e.message}")
    end
  end
end
