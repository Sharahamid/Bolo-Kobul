# Homepage shows "120+": start at 120 (only if the first value, 127, is still there)
class SetMarriagesTo120 < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE site_stats SET marriages_count = 120, updated_at = NOW() WHERE marriages_count = 127"
  end

  def down; end
end
