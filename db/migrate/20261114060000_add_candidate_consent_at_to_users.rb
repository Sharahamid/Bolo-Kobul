# When someone registers a profile for another person (parent, sibling, matchmaker...),
# the time they confirmed: candidate's permission, true details, candidate 18 or older
class AddCandidateConsentAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :candidate_consent_at, :datetime
  end
end
