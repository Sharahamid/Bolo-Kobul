class RemoveLivingWithFromLifeStyles < ActiveRecord::Migration[6.0]
  def change

    remove_column :life_styles, :living_with, :integer
  end
end
