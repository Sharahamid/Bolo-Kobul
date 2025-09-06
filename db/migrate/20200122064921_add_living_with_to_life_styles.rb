class AddLivingWithToLifeStyles < ActiveRecord::Migration[6.0]
  def change
    add_column :life_styles, :living_with, :string
  end
end
