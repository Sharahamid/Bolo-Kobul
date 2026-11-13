# Numbers shown on the homepage that admin can change (Admin > Settings > Homepage numbers)
class CreateSiteStats < ActiveRecord::Migration[8.1]
  def up
    create_table :site_stats do |t|
      t.integer :marriages_count, null: false, default: 0
      t.timestamps
    end
    execute "INSERT INTO site_stats (marriages_count, created_at, updated_at) VALUES (127, NOW(), NOW())"
  end

  def down
    drop_table :site_stats
  end
end
