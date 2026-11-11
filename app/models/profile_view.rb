# One member looked at another member's profile. Kept for 90 days.
class ProfileView < ApplicationRecord
  KEEP_FOR = 90.days

  belongs_to :viewer, class_name: 'MarriageProfile'
  belongs_to :viewed, class_name: 'MarriageProfile'

  # Record a visit (never fails the page)
  def self.record!(viewer, viewed)
    return if viewer.nil? || viewed.nil? || viewer.id == viewed.id
    return if viewer.user_id.present? && viewer.user_id == viewed.user_id # own other profile

    now = Time.current
    upsert({ viewer_id: viewer.id, viewed_id: viewed.id, views_count: 1, last_viewed_at: now,
             created_at: now, updated_at: now },
           unique_by: %i[viewed_id viewer_id],
           on_duplicate: Arel.sql('views_count = profile_views.views_count + 1, ' \
                                  'last_viewed_at = EXCLUDED.last_viewed_at, updated_at = EXCLUDED.updated_at'))
  rescue StandardError => e
    Rails.logger.warn("[ProfileView] #{e.class}: #{e.message}")
    nil
  end

  # Visits to this profile in the last 30 days, newest first, leaving out members it
  # has blocked or who blocked it
  def self.recent_for(profile, since: 30.days.ago)
    blocked = profile.blocked_friend_ids
    where(viewed_id: profile.id).where('last_viewed_at > ?', since)
      .where.not(viewer_id: blocked).order(last_viewed_at: :desc)
  rescue ActiveRecord::StatementInvalid
    none # table not created yet (before the database update runs)
  end
end
