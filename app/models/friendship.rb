class Friendship < ApplicationRecord
  belongs_to :friendable, class_name: "MarriageProfile"
  belongs_to :friend, class_name: "MarriageProfile"

  enum status: { pending: 0, accepted: 1, declined: 2 }

  # Scopes
  scope :pending_for, ->(profile) { where("(friendable_id = ? OR friend_id = ?) AND status = ?", profile.id, profile.id, :pending) }
  scope :requested_by, ->(profile) { where(friend: profile, status: :pending) }
  scope :accepted_for, ->(profile) { where("(friendable_id = ? OR friend_id = ?) AND status = ?", profile.id, profile.id, :accepted) }
  scope :blocked_for, ->(profile) { where("(friendable_id = ? OR friend_id = ?) AND blocked = ?", profile.id, profile.id, true) }

  # Add declined scope for clarity
  scope :declined_for, ->(profile) { where("(friendable_id = ? OR friend_id = ?) AND status = ?", profile.id, profile.id, :declined) }

  # Accept a friendship
  def accept!
    update(status: :accepted)
  end

  # Decline or cancel a friendship
  def decline!
    update(status: :declined)
  end

  # Returns the friendship between two profiles
  def self.between(profile1, profile2)
    find_by(friendable: profile1, friend: profile2) || find_by(friendable: profile2, friend: profile1)
  end

  # Block the friendship
  def block!
    update(blocked: true)
  end

  # Unblock the friendship
  def unblock!
    update(blocked: false) if blocked?
  end

  # Check if blocked
  def blocked?
    blocked
  end
end
