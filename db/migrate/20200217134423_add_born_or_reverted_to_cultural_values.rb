class AddBornOrRevertedToCulturalValues < ActiveRecord::Migration[6.0]
  def change
    add_column :cultural_values, :born_or_reverted, :integer
  end
end
