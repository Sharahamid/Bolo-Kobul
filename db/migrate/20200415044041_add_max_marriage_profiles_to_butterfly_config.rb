class AddMaxMarriageProfilesToButterflyConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :butterfly_configs, :max_marriage_profiles, :integer, default: 5
  end
end
