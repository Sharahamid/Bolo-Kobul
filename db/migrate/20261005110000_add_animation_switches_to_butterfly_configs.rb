# These admin switches were added to the live database by hand; this records them so a
# rebuilt database matches. On the live site the columns already exist, so it changes nothing.
class AddAnimationSwitchesToButterflyConfigs < ActiveRecord::Migration[6.1]
  def change
    add_column :butterfly_configs, :anim_kobul1_recommendations, :boolean, default: true, if_not_exists: true
    add_column :butterfly_configs, :anim_kobul1_request, :boolean, default: true, if_not_exists: true
    add_column :butterfly_configs, :anim_kobul2, :boolean, default: true, if_not_exists: true
  end
end
