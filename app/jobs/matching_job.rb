class MatchingJob < ApplicationJob
  def perform(*args)
    Rails.logger.info  "---------------------------Active job is running---------------"
    Rails.logger.info "passing info to the job is #{args.inspect}"
  end
end
