class AddAdvSearchButterfliesToButterflyConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :butterfly_configs, :adv_search_butterflies, :integer, default: 0
  end
end
