# A member passed on another profile (declined their 1st or 2nd Kobul). Those profiles
# stop appearing in the member's daily recommendations, and the member no longer
# appears in theirs. Search still finds them.
class ProfilePass < ApplicationRecord
  belongs_to :marriage_profile
  belongs_to :passed_profile, class_name: 'MarriageProfile'

  def self.record!(member, other)
    return if member.nil? || other.nil? || member.id == other.id

    find_or_create_by!(marriage_profile_id: member.id, passed_profile_id: other.id)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid => e
    Rails.logger.warn("[ProfilePass] #{e.class}: #{e.message}")
    nil
  end

  # Everyone this member should not be recommended: people they passed on, and
  # people who passed on them
  def self.hidden_ids_for(profile)
    where(marriage_profile_id: profile.id).pluck(:passed_profile_id) +
      where(passed_profile_id: profile.id).pluck(:marriage_profile_id)
  rescue ActiveRecord::StatementInvalid
    [] # table not created yet (before the database update runs)
  end
end
