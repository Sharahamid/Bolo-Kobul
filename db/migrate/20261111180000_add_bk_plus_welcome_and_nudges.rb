# November 2026: BK+ membership, the 3-card welcome, and daily friendly nudges
class AddBkPlusWelcomeAndNudges < ActiveRecord::Migration[8.1]
  def change
    # BK+ (paid membership): active while bk_plus_until is in the future
    add_column :users, :bk_plus_until, :datetime
    # Welcome cards: shown once
    add_column :users, :welcome_seen_at, :datetime
    # Daily nudges ("3 new matches this week"): members can turn them off
    add_column :users, :nudges_enabled, :boolean, default: true, null: false
    add_column :users, :last_nudge_at, :datetime

    # BK+ settings in Admin > Butterfly Config
    add_column :butterfly_configs, :bk_plus_price, :float, default: 0.0
    add_column :butterfly_configs, :bk_plus_days, :integer, default: 30
    add_column :butterfly_configs, :bk_plus_butterflies, :integer, default: 5

    # Which order gave BK+ (so a payment is never counted twice)
    add_column :orders, :bk_plus_applied, :boolean, default: false, null: false
  end
end
