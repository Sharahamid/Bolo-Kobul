# "Not interested": the member never sees that profile again in recommendations, search or
# advanced search. One-way (the other member is not told and still sees this member).
# Undo: Account settings > Blocked & hidden profiles > Show again.
class ProfileHide < ApplicationRecord
  belongs_to :marriage_profile
  belongs_to :hidden_profile, class_name: 'MarriageProfile'

  def self.hide!(member, other)
    return if member.nil? || other.nil? || member.id == other.id

    find_or_create_by!(marriage_profile_id: member.id, hidden_profile_id: other.id)
  rescue ActiveRecord::RecordNotUnique
    nil
  end

  def self.hidden_ids_for(profile)
    return [] unless profile

    where(marriage_profile_id: profile.id).pluck(:hidden_profile_id)
  rescue ActiveRecord::StatementInvalid
    [] # table not created yet (before the database update runs)
  end
end
