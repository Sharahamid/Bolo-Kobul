# BK+ plans (week / month / year), each with its own price and bonus butterflies,
# managed in Admin > BK+ Plans. Orders remember which plan was bought.
class CreateBkPlusPlans < ActiveRecord::Migration[8.1]
  def up
    create_table :bk_plus_plans do |t|
      t.integer :days, null: false
      t.float :price, null: false, default: 0
      t.integer :butterflies, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_column :orders, :bk_plus_plan_id, :integer

    now = Time.current
    execute <<~SQL
      INSERT INTO bk_plus_plans (days, price, butterflies, position, active, created_at, updated_at) VALUES
        (7, 300, 5, 1, TRUE, '#{now.to_fs(:db)}', '#{now.to_fs(:db)}'),
        (30, 1000, 25, 2, TRUE, '#{now.to_fs(:db)}', '#{now.to_fs(:db)}'),
        (365, 8000, 500, 3, TRUE, '#{now.to_fs(:db)}', '#{now.to_fs(:db)}')
    SQL
  end

  def down
    remove_column :orders, :bk_plus_plan_id
    drop_table :bk_plus_plans
  end
end
